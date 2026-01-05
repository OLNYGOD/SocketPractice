const net = require('net');
const clients = {}; // userId → socket

const server = net.createServer(socket => {
    console.log('Client connected');

    socket.setKeepAlive(true);

    socket.on('data', raw => {
        const data = JSON.parse(raw.toString());
        
        console.log('Data received:', data);

        // 使用者註冊
        if (data.type === "register") {
            clients[data.userId] = { socket,
            lastSeen: Date.now()}
            console.log(`${data.userId} registered`);
            return;
        }

        // 傳訊息：Server 轉發
        if (data.type === "message") {
            const target = clients[data.to];
            if (target && target.socket) {
                target.socket.write(JSON.stringify({
                    from: data.from,
                    text: data.text
                }));
            }
        }

         socket.on('end', () => {
        // 移除離線
        for (const id in clients) {
            if (clients[id] === socket) delete clients[id];
            console.log('Client disconnected');
         }
        });

        console.log('Received:', data);

        // 🔥 心跳處理
        if (data.type === 'ping') {
            const userId = data.userId;
            if (clients[userId]) {
            clients[userId].lastSeen = Date.now();
            }
            return;
        }
        // 收到特定type 則回傳特定訊息
        // if (msg === 'PING') {
        //     socket.write('PONG\n');
        // }

        // if (msg === 'HELLO') {
        //     socket.write('Hi, iOS client!\n');
        // }

        // if (msg === 'TIME') {
        //     socket.write(`Server time: ${new Date().toLocaleString()}\n`);
        // }
    });

    // Server 主動推送訊息給 Client（每 5 秒一次）
    // const interval = setInterval(() => {
    //     socket.write(`Server broadcast: ${Date.now()}\n`);
    // }, 5000);


    // socket.on('end', () => {
    //     clearInterval(interval);
    //     console.log('Client disconnected');
    // });

    socket.on('error', err => {
        console.log('Socket error:', err.message);
    });
});

setInterval(() => {
  const now = Date.now();
  for (const id in clients) {
    if (now - clients[id].lastSeen > 30000) {
      console.log(`${id} timeout`);
      clients[id].socket.destroy();
      delete clients[id];
    }
  }
}, 5000);

server.listen(3000, () => {
    console.log('Server listening on port 3000');
});