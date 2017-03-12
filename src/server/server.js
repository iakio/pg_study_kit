const express = require('express');
const app = express();
const http = require('http').createServer(app);
const io = require('socket.io')(http);
const pg = require('pg');

app.use(express.static('public'));
app.get('/relations/:relname', (req, res) => {
    const client = new pg.Client({
        // database: 'pagila'
    });
    client.connect();
    client.on('drain', client.end.bind(client));
    client.query(`select * from pg_class where relname = $1`, [req.params.relname], (err, result) => {
        res.send(result.rows);
    });
});

let fragment = '';
process.stdin.on('data', function (data) {
    if (data !== null) {
        let lines = data.toString('utf-8').split(/\n/);
        lines[0] = fragment + lines[0];
        fragment = lines.pop();
        lines.forEach(function (line) {
            if (line) {
                try {
                    io.emit('message', JSON.parse(line));
                }
                catch (ex) {
                    console.error(ex);
                }
            }
        });
    }
});

http.listen(3000, function () {
    console.log('listening on *:3000');
});
