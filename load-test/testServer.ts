import axios from "axios";
import * as http from "http";
import express from "express";
import { EventEmitter } from "events";

let stop = false;

require("dotenv").config();
class Counter extends EventEmitter {
  count = 0;
  inc() {
    this.count++;
    this.emit("INC", this.count);
  }
}

let counter = new Counter();

function publishMessage() {
  axios.post("http://167.172.157.251/pub?id=test", "abc", {
    headers: {
      Authorization: process.env.SHARED_SECRET,
    },
  });
  // axios.post("http://localhost:8080/pub?id=test", "abc");
}

async function makeConnections(
  max: number,
  counter: Counter,
  connections: http.ClientRequest[]
) {
  for (let i = 0; i < max; i++) {
    console.log(i);
    let one = await makeOne(counter);
    if (stop) {
      break;
    }
    connections.push(one);
  }
  console.log("done");
}

async function closeConnections(connections: http.ClientRequest[]) {
  for (let connection of connections) {
    connection.end();
  }
  connections = [];
}

function makeOne(counter: Counter): Promise<http.ClientRequest> {
  return new Promise((resolve, reject) => {
    let one = http
      .get(
        {
          agent: false,
          path: "/sub/test",
          hostname: "167.172.157.251",
          // hostname: "localhost",
          // port: "8080",
          timeout: 10000000,
        },
        (res) => {
          res.on("data", (data) => {
            counter.inc();
          });
          res.on("error", console.log);
          resolve(one);
        }
      )
      .on("error", (error) => {
        console.log(error);
        makeOne(counter).then((one) => resolve(one));
      });
  });
}

const app = express();

app.get("/", (req, res) => {
  res.sendFile(__dirname + "/index.html");
});

// app.post("/queue/:num", async (req, res) => {
//   let conns=[]
//   await makeConnections(parseInt(req.params.num), counter,conns);
//   res.sendStatus(200);
// });

// app.post("/clear", (req, res) => {
//   closeConnections();
//   res.sendStatus(200);
// });

app.post("/test/:num", async (req, res) => {
  let counter = new Counter();
  let conns: http.ClientRequest[] = [];
  await makeConnections(parseInt(req.params.num), counter, conns);
  counter.count = 0;
  let t0 = Date.now();
  let retArr: number[] = [];
  counter.on("INC", (count) => {
    retArr.push(Date.now() - t0);
    if (count === parseInt(req.params.num)) {
      closeConnections(conns);
      counter.removeAllListeners("INC");
      res.send(retArr);
    }
  });

  await publishMessage();
});

app.listen(5500);
