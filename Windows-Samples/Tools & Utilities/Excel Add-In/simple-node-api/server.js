const certDomain = require('./node_modules/office-addin-dev-certs/lib/defaults').domain;
const fs = require('fs');

function readWriteSync() {
  if (certDomain.length === 2) {
    let data = fs.readFileSync('node_modules/office-addin-dev-certs/lib/defaults.js', 'utf-8');
    let newValue = data.replace(/\["127.0.0.1", "localhost"\]/gim, '["127.0.0.1", "localhost", os.hostname()]');

    fs.writeFileSync('node_modules/office-addin-dev-certs/lib/defaults.js', newValue, 'utf-8');
  }
}
readWriteSync();

const devCerts = require('office-addin-dev-certs');
let cluster = require('cluster');

if (cluster.isMaster) {
  let numWorkers = 2;

  console.log('Master cluster setting up ' + numWorkers + ' workers...');

  for (let i = 0; i < numWorkers; i++) {
    cluster.fork();
  }

  cluster.on('online', function(worker) {
    console.log('Worker ' + worker.process.pid + ' is online');
  });

  cluster.on('exit', function(worker, code, signal) {
    console.log('Worker ' + worker.process.pid + ' died with code: ' + code + ', and signal: ' + signal);
    console.log('Starting a new worker');
    cluster.fork();
  });
} else {

  const express = require('express');
  const serveStatic = require('serve-static');
  const https = require('follow-redirects').https;
  const bodyParser = require('body-parser');
  const path = require('path');

  const app = express();
  const Agent = require('agentkeepalive');


  const keepAliveAgent = new Agent({
    maxSockets: 40,
    maxFreeSockets: 10,
    timeout: 600000, // active socket keepalive for 60 seconds
    freeSocketTimeout: 300000 // free socket keepalive for 30 seconds
  });


  let useRedis = true;
  useRedis = useRedis && fs.existsSync('ca/certs/localhost.crt');
  if (useRedis) {
    const bluebird = require('bluebird');
    let redis = require('redis');
    let client = redis.createClient();
    bluebird.promisifyAll(redis.RedisClient.prototype);
    bluebird.promisifyAll(redis.Multi.prototype);

    client.on('error', function(err) {
      console.log('Something went wrong ', err);
    });
  }


  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: true }));
  const port = process.env.PORT || 1337;

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

    let myQueries = queryBuilder(queries);
    let query;
    if (myQueries.length > 1) {
      query = myQueries;
    } else {
      query = '';
    }
    let paramString = '/api';
    for (let i = 0; i < params.length; i++) {
      paramString = paramString + '/' + params[i];
    }
    return paramString + query;
  };

  app.get('/wsoneapi', async (req, res0) => {
    const {
      authorization,
      domain,
      path,
      username,
      usecache
    } = req.headers;
    console.log(req.headers);
    const awTenantCode = req.headers['aw-tenant-code'];
    if (!authorization) {
      console.log('error: You are not authorized!');
      return res0.status(401).send({ error: 'You are not authorized!' });
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
        'aw-tenant-code': awTenantCode,
        'Accept': 'application/json;version=2;',
        'Cookie': '__cfduid=deed201afd27e50d8dc45ea9a40b913f91587694655'
      },
      'maxRedirects': 20
    };

    let queryPath = options.hostname + options.path;
    let result = null;
    if (usecache === 'true') {
      if (useRedis) {
        // let start = Date.now();
        await client.getAsync(queryPath).then((reply) => {
          result = reply;
        });
      }
    }
    if (result) {
      console.log('found ' + queryPath);
      let data;
      if (useRedis) {
        try {
          data = JSON.parse(result);
        } catch (e) {
          console.log(e);
          data = { error: e };
        }
      }
      res0.send(data);
    } else {
      try {
        https.request(options, function(res) {
          let chunks = [];

          res.on('data', function(chunk) {
            chunks.push(chunk);
          });

          res.on('end', function() {
            let body = Buffer.concat(chunks);
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
            let responseTime = Date.now() - start;
            console.log(ip + ' ' + options.hostname + options.path + ' ResponseTime:' + responseTime + 'ms');
            if (body.toString() !== '') {
              if (useRedis) {
                client.set(
                  queryPath,
                  JSON.stringify(body.toString()),
                  redis.print
                );
              }
            }

            res0.send(body);
          });

          res.on('error', function(error) {
            console.error(error);
          });
        }).end();
      } catch (e) {
        console.log(e);
      }

    }
  });

  app.use(serveStatic(path.join(__dirname, 'www'), { 'index': ['index.html'] }));


  // app.listen(port, () => {
  //   console.log('Listening on http://localhost:' + port + '/');
  // });


  try {
    devCerts.getHttpsServerOptions().then(options => {
      console.log(certDomain);
      let credentials = { key: options.key.toString(), cert: options.cert.toString() };
      let httpsServer = https.createServer(credentials, app);
      let sslPort = 443;
      httpsServer.listen(sslPort, () => {
        console.log(new Date().toLocaleTimeString());
        for (let i = 0; i < certDomain.length; i++) {
          console.log('Listening on https://' + certDomain[i] + ':' + sslPort);
        }
      });
    });
  } catch (err) {
    console.error(err);
  }
}

