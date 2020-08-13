# simple_node_api to use as a backend for the Excel Add-In

Create a folder to hold this on your computer which will host the Excel Add-In.
This server will be the API proxy which serves the Add-In to Excel and allows the Excel Add-In to connect to the Workspace ONE API server you unlimately connect to.

Note: This NodeJS server is a basic implementation kept simple on purpose.  If you know of ways to make it more robust, feel free to let me know. [Leon Letto](mailto:leon.letto@gmail.com)

The Application itself will be in a separate folder to facilitate updating as new versions come out.  See it in the "Excel Add-In/app" folder.
You need to copy that folder into the www folder to allow it to be served.

eg.

    Server -
        - ca ( basic openssl Certificate Authority if you don't have one already)
        - www (Instructions)
            -app (all app files)

# Included CA

I have included a set of scripts which will generate an openssl CA for you automatically.
If you decide to use this, your computer will need openssl installed.
In order to trust the certificates generated here, just get the yourcaname.crt file which you generated when creating your CA and trust it by double clicking on it.

# Certificates

If you have a ca and generate your own certificates, then need to be in standard Base64 encoded format.
The server.js has a reference to localhost.key and localhost.crt files.
Please rename your files to match or edit the server.js file.

# run the server
Your computer needs to have NodeJS installed with NPM.
In the Server directory, run:

    npm install
    npm start
    
Thank you and I hope you find this helpful.

Leon Letto

lettol@vmware.com
