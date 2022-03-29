const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const axios = require("axios");
require("dotenv").config();

const app = express();
const port = 3000;
const API_KEY = process.env.API_KEY;

app.use(bodyParser.json());
app.use(cors());

// 4.1.1
app.get("/getCompanyDescription", async (req, res) => {
  let { ticker } = req.query;
  if (ticker) {
    ticker = ticker.toUpperCase();
  }
  const url = `https://finnhub.io/api/v1/stock/profile2?symbol=${ticker}&token=${API_KEY}`;
  let response = {};
  await axios
    .get(url)
    .then((res) => {
      response = res.data;
    })
    .catch((err) => {
      response.data = err;
      response.error = true;
    });
  res.status(200).send(response);
});

// 4.1.2
app.get("/getHistoricalData", async (req, res) => {
  let { ticker, timeInterval, fromTimestamp, toTimestamp } = req.query;
  ticker = ticker.toUpperCase();
  const url = `https://finnhub.io/api/v1/stock/candle?symbol=${ticker}&resolution=${timeInterval}&from=${fromTimestamp}&to=${toTimestamp}&token=${API_KEY}`;
  let response = {};
  await axios
    .get(url)
    .then((res) => {
      response.close = res.data.c;
      response.high = res.data.h;
      response.low = res.data.l;
      response.open = res.data.o;
      response.timestamp = res.data.t;
      response.volume = res.data.v;
    })
    .catch((err) => {
      response.data = err;
      response.error = true;
    });
  res.status(200).send(response);
});

// 4.1.3
app.get("/getLatestPrice", async (req, res) => {
  let { ticker } = req.query;
  if (ticker) {
    ticker = ticker.toUpperCase();
  }
  const url = `https://finnhub.io/api/v1/quote?symbol=${ticker}&token=${API_KEY}`;
  let response = {};
  await axios
    .get(url)
    .then((res) => {
      response.price = res.data.c.toFixed(2);
      response.change = res.data.d.toFixed(2);
      response.percentChange = res.data.dp.toFixed(2);
      response.high = res.data.h.toFixed(2);
      response.low = res.data.l.toFixed(2);
      response.open = res.data.o.toFixed(2);
      response.previousClose = res.data.pc.toFixed(2);
      response.timestamp = res.data.t;
    })
    .catch((err) => {
      response.data = err;
      response.error = true;
    });
  res.status(200).send(response);
});

// 4.1.4
app.get("/autocomplete", async (req, res) => {
  let { query } = req.query;
  const url = `https://finnhub.io/api/v1/search?q=${query}&token=${API_KEY}`;
  let response = {};
  await axios
    .get(url)
    .then((res) => {
      response = res.data.result.map((res) => {
        const data = {
          description: res.description,
          displaySymbol: res.displaySymbol,
        };
        // return `${data.displaySymbol} | ${data.description}`;
        return data;
      });
    })
    .catch((err) => {
      response.data = err;
      response.error = true;
    });
  res.status(200).send(response);
});

// 4.1.5
app.get("/getCompanyNews", async (req, res) => {
  let { ticker, fromDate, toDate } = req.query;
  ticker = ticker.toUpperCase();
  const url = `https://finnhub.io/api/v1/company-news?symbol=${ticker}&from=${fromDate}&to=${toDate}&token=${API_KEY}`;
  let response = {};
  await axios
    .get(url)
    .then((res) => {
      response = res.data
        .filter(
          (news) =>
            news.source &&
            news.datetime &&
            news.headline &&
            news.summary &&
            news.url &&
            news.image
        )
        .slice(0, 20);
    })
    .catch((err) => {
      response.data = err;
      response.error = true;
    });
  res.status(200).send(response);
});

// 4.1.6
app.get("/getCompanyRecommendationTrends", async (req, res) => {
  let { ticker } = req.query;
  ticker = ticker.toUpperCase();
  const url = `https://finnhub.io/api/v1/stock/recommendation?symbol=${ticker}&token=${API_KEY}`;
  let response = {};
  await axios
    .get(url)
    .then((res) => {
      response = res.data;
    })
    .catch((err) => {
      response.data = err;
      response.error = true;
    });
  res.status(200).send(response);
});

// 4.1.7
app.get("/getCompanySocialSentiment", async (req, res) => {
  let { ticker } = req.query;
  ticker = ticker.toUpperCase();
  const url = `https://finnhub.io/api/v1/stock/social-sentiment?symbol=${ticker}&from=2022-01-01&token=${API_KEY}`;
  let response = {};
  await axios
    .get(url)
    .then((res) => {
      response = res.data;
    })
    .catch((err) => {
      response.data = err;
      response.error = true;
    });
  res.status(200).send(response);
});

// 4.1.8
app.get("/getCompanyPeers", async (req, res) => {
  let { ticker } = req.query;
  ticker = ticker.toUpperCase();
  const url = `https://finnhub.io/api/v1/stock/peers?symbol=${ticker}&token=${API_KEY}`;
  let response = {};
  await axios
    .get(url)
    .then((res) => {
      response = res.data;
    })
    .catch((err) => {
      response.data = err;
      response.error = true;
    });
  res.status(200).send(response);
});

// 4.1.9
app.get("/getCompanyEarnings", async (req, res) => {
  let { ticker } = req.query;
  ticker = ticker.toUpperCase();
  const url = `https://finnhub.io/api/v1/stock/earnings?symbol=${ticker}&token=${API_KEY}`;
  let response = {};
  await axios
    .get(url)
    .then((res) => {
      response = res.data;
    })
    .catch((err) => {
      response.data = err;
      response.error = true;
    });
  res.status(200).send(response);
});

app.listen(port, () => {
  console.log(`Server listening on the port:${port}`);
});
