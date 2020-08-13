const express = require('express');
const serveStatic = require('serve-static');
const https = require('follow-redirects').https;
const bodyParser = require('body-parser');
const path = require('path');
const fs = require('fs');
const app = express();
const Agent = require('agentkeepalive');

const keepAliveAgent = new Agent({
  maxSockets: 40,
  maxFreeSockets: 10,
  timeout: 600000, // active socket keepalive for 60 seconds
  freeSocketTimeout: 300000, // free socket keepalive for 30 seconds
});


app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));
const port = process.env.PORT || 4444;

const queryBuilder = (queries1) => {
  let params = '';
  for (const query in queries1) {
    params = params + query + '=' + encodeURIComponent(queries1[query]) + '&';
  }
  if (params.length > 1) {
    params = params.substring(0, params.length - 1);
  }
  return '?' + params;
};


const requestBuilder2 = (params, queries) => {

  let myqueries = queryBuilder(queries);
  let query;
  if (myqueries.length > 1) {
    query = myqueries;
  } else {
    query = '';
  }
  let paramstring = '/api';
  for (let i = 0; i < params.length; i++) {
    paramstring = paramstring + '/' + params[i];
  }
  return paramstring + query;
};

app.get('/wsoneapi', async (req, res0) => {
  const {
    authorization,
    domain,
    path,
    username,
  } = req.headers;
  const awtenantcode = req.headers['aw-tenant-code'];
  if (!authorization) {
    console.log('error: You are not authorized!');
    return res0.status(401).send({error: 'You are not authorized!'});
  }
  let start = Date.now();
  let ip =
    (req.headers['x-forwarded-for'] || '')
      .split(',')
      .pop()
      .trim() ||
    req.connection.remoteAddress ||
    (req.connection && req.connection.remoteAddress) ||
    req.socket.remoteAddress ||
    (req.socket && req.socket.remoteAddress) ||
    req.connection.socket.remoteAddress ||
    undefined;

  let options = {
    keepAliveAgent: keepAliveAgent,
    'method': 'GET',
    'hostname': domain,
    path: requestBuilder2(
      JSON.parse(path),
      req.query
    ),
    'headers': {
      'Authorization': authorization,
      'aw-tenant-code': awtenantcode,
      'Accept': 'application/json;version=2;',
      'Cookie': '__cfduid=deed201afd27e50d8dc45ea9a40b913f91587694655'
    },
    'maxRedirects': 20
  };
  try {
    https.request(options, function (res) {
      let chunks = [];

      res.on('data', function (chunk) {
        chunks.push(chunk);
      });

      res.on('end', function () {
        var body = Buffer.concat(chunks);
        if (options.path.split('/')[3] === 'admins') {
          let adminJson;
          let admins;
          try {
            adminJson = JSON.parse(body.toString());
            admins = adminJson['Admins'];
          } catch (e) {
            console.log(e); // error in the above string (in this case, yes)!
          }
          if (admins) {
            for (let i = 0; i < admins.length; i++) {
              if (admins[i]['UserName'] === username) {
                console.log(
                  `admin user ${admins[i]['UserName']} from Org: ${admins[i]['LocationGroup']} in env ${options.hostname} logged in.`
                );
              }
            }
          }

        }
        let restime = Date.now() - start;
        console.log(ip + ' ' + options.hostname + options.path + ' ResponseTime:' + restime + 'ms');
        res0.send(body);
      });

      res.on('error', function (error) {
        console.error(error);
      });
    }).end();
  } catch (e) {
    console.log(e);
  }
});

app.use(serveStatic(path.join(__dirname, 'src/pages'), {'index': ['index.html']}));

try {
  if (fs.existsSync('ca/privatekeys/localhost.key')) {
    const privateKey = fs.readFileSync('ca/privatekeys/localhost.key', 'utf8');
    const certificate = fs.readFileSync('ca/certs/localhost.crt', 'utf8');
    const credentials = {key: privateKey, cert: certificate};
    let httpsServer = https.createServer(credentials, app);
    httpsServer.listen(port, () => {
      console.log('Listening on https://localhost:' + port + '/');
    });
  } else {
    console.log(`You must run the createCa.sh script to create your keys.
    Remember to use a hostname which matches the computer you are hosting this on.`);
  }
} catch (err) {
  console.error(err);
}
