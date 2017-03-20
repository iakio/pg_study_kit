const socket = io();
const WIDTH = 640;
const SCALE = 16;
class View {
    constructor(relname, relpages, relfilenode) {
        let div = document.createElement("div");
        let canvas = document.createElement("canvas");
        div.innerHTML = '<h3>' + relname + '(' + relfilenode + ')' + '</h3>';
        div.appendChild(canvas);
        this.div = div;
        this.ctx = canvas.getContext("2d");
        this.canvas = canvas;
        this.relpages = relpages;
        this.setSize();
    }
    setSize() {
        let height = Math.ceil(this.relpages / (WIDTH / SCALE)) * SCALE;
        if (height != this.height || WIDTH != this.width) {
            this.width = WIDTH;
            this.height = height;
            this.canvas.setAttribute("width", String(WIDTH));
            this.canvas.setAttribute("height", String(this.height));
        }
    }
    point(blockNo, hit) {
        const x = blockNo % (WIDTH / SCALE);
        const y = (blockNo / (WIDTH / SCALE)) | 0;
        if (blockNo + 1 > this.relpages) {
            this.relpages = blockNo + 1;
            this.setSize();
        }
        if (hit) {
            this.ctx.fillStyle = "#00c";
            this.ctx.fillRect(x * SCALE + 2, y * SCALE + 2, SCALE - 4, SCALE - 4);
        }
        else {
            this.ctx.fillStyle = "#f00";
            this.ctx.fillRect(x * SCALE, y * SCALE, SCALE, SCALE);
        }
    }
}
const map = new Map();
function register(relname) {
    return fetch('/relations/' + relname);
}
document.addEventListener('DOMContentLoaded', () => {
    let promises = [
        register('pgbench_accounts'),
        register('pgbench_accounts_pkey'),
        // register('t1'),
        // register('t1_pkey'),
        // register('t2'),
        // register('t2_pkey'),
    ];
    Promise.all(promises).then(values => {
        values.forEach(res => {
            res.json().then(relations => {
                let view = new View(relations[0].relname, relations[0].relpages, relations[0].relfilenode);
                map.set(relations[0].relfilenode, view);
                document.body.appendChild(view.div);
            });
        });
    });
});
setInterval(() => {
    for (let [rel, view] of map) {
        var ctx = view.ctx;
        ctx.fillStyle = 'rgba(255,255,255,0.1)';
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    }
}, 100);
socket.on("message", msg => {
    var [rel, blockNo, hit] = msg;
    if (map.has(rel)) {
        map.get(rel).point(blockNo, hit);
    }
});
