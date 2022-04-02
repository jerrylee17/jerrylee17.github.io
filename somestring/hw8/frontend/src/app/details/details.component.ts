import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { APIService } from '../apiFunctions/apiFunctions';
import { companyDescription } from '../interfaces/companyDescription';
import { historicalData } from '../interfaces/historicalData';
import { latestPrice } from '../interfaces/latestPrice';
import * as Highcharts from 'highcharts/highstock';
import { Options } from 'highcharts';
import { companyNews } from '../interfaces/companyNews';
import vbp from 'highcharts/indicators/volume-by-price';
import indicators from 'highcharts/indicators/indicators';
import { companySocialSentiment } from '../interfaces/companySocialSentiment';
import { socialData } from '../interfaces/socialData';
import { recommendationTrends } from '../interfaces/recommendationTrends';
import { companyEarnings } from '../interfaces/companyEarnings';
import { debounceTime, interval, Observable, Subject, timer } from 'rxjs';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { TransactionModalComponent } from '../transaction-modal/transaction-modal.component';
import { NewsModalComponent } from '../news-modal/news-modal.component';
indicators(Highcharts);
vbp(Highcharts);

@Component({
  selector: 'app-details',
  templateUrl: './details.component.html',
  styleUrls: ['./details.component.css'],
})
export class DetailsComponent implements OnInit {
  ticker: string = '';
  tickerExist;
  change: number = 0;
  currentTimestamp: string = '';
  watchListed: boolean = false;
  marketOpen;
  lastTimestamp;
  marketLastTimestamp: string = '';
  companyDescription: companyDescription;
  latestPrice: latestPrice;
  smallChartData: historicalData;
  smallChartOptions: Options;
  HighCharts: typeof Highcharts = Highcharts;
  smallChartDone: boolean = false;
  bigChartDone: boolean = false;
  companyNews: companyNews[];
  bigChartData: historicalData;
  bigChartOptions: Options;
  socialData: socialData;
  recommendationChartOptions: Options;
  recommendationChartData: recommendationTrends[];
  socialSentimentDone: boolean = false;
  recommendationDone: boolean = false;
  earningChartOptions: Options;
  earningChartData: companyEarnings[];
  companyPeers;
  companyPeersDone: boolean = false;
  starMessage: boolean = false;
  starAlert = new Subject<string>();
  purchaseMessage = false;
  purchaseAlert = new Subject<string>();
  sellMessage = false;
  sellAlert = new Subject<string>();
  sellBtnVisibility: boolean = false;
  apiError: boolean = false;
  updateSummarySub;

  constructor(
    private ModalService: NgbModal,
    private APIService: APIService,
    private route: ActivatedRoute
  ) {}

  openNews(news: companyNews) {
    const modalRef = this.ModalService.open(NewsModalComponent);
    modalRef.componentInstance.news = news;
  }

  openTransaction(ticker, name, price, opt) {
    const modalRef = this.ModalService.open(TransactionModalComponent);
    modalRef.componentInstance.ticker = ticker;
    modalRef.componentInstance.name = name;
    modalRef.componentInstance.price = price;
    modalRef.componentInstance.opt = opt;
    modalRef.result.then(() => {
      if (opt == 'buy') this.purchaseAlert.next('next');
      else this.sellAlert.next('next');
      this.setSellBtn();
    });
  }

  setSellBtn() {
    if (
      JSON.parse(localStorage.getItem('portfolio') || '[]').filter(
        (x) => x.ticker == this.companyDescription.ticker
      ).length
    ) {
      this.sellBtnVisibility = true;
    } else {
      this.sellBtnVisibility = false;
    }
  }

  ngOnInit(): void {
    this.route.paramMap.subscribe((params) => {
      this.ticker = (params.get('ticker') || '').toUpperCase();
    });

    this.fetchCompanyDescription();
    this.fetchLatestPrice();
    this.fetchCompanyNews();
    this.fetchBigChart();
    this.fetchCompanyInsights();
    this.fetchCompanyPeers();
    this.fetchWatchList();

    this.starAlert.subscribe(() => (this.starMessage = true));

    this.starAlert
      .pipe(debounceTime(5000))
      .subscribe(() => (this.starMessage = false));

    this.purchaseAlert.subscribe((res) => {
      if (res) this.purchaseMessage = true;
    });

    this.purchaseAlert
      .pipe(debounceTime(5000))
      .subscribe(() => (this.purchaseMessage = false));

    this.sellAlert.subscribe((res) => {
      if (res) this.sellMessage = true;
    });

    this.sellAlert
      .pipe(debounceTime(5000))
      .subscribe(() => (this.sellMessage = false));
  }

  fetchWatchList() {
    let watchList = JSON.parse(localStorage.getItem('watchlist') || '[]');
    let r = watchList.filter((x) => x.ticker == this.ticker.toUpperCase());
    if (r.length) {
      this.watchListed = true;
    } else {
      this.watchListed = false;
    }
  }

  onClickStar() {
    this.watchListed = !this.watchListed;
    let watchList = JSON.parse(localStorage.getItem('watchlist') || '[]');
    if (this.watchListed) {
      let x = {
        ticker: this.ticker.toUpperCase(),
        name: this.companyDescription.name,
      };
      watchList.push(x);
      localStorage.setItem('watchlist', JSON.stringify(watchList));
    } else {
      let x = watchList.filter((r) => r.ticker != this.ticker.toUpperCase());
      localStorage.setItem('watchlist', JSON.stringify(x));
    }
    this.starAlert.next('next');
  }

  fetchCompanyPeers() {
    this.APIService.fetchCompanyPeers(this.ticker).subscribe((res) => {
      this.companyPeers = res;
      this.companyPeersDone = true;
    });
  }

  fetchCompanyInsights() {
    // Get company social sentiment
    this.APIService.fetchCompanySocialSentiment(this.ticker).subscribe(
      (res) => {
        // sum up reddit
        let rtm = 0,
          rpm = 0,
          rnm = 0,
          ttm = 0,
          tpm = 0,
          tnm = 0;
        for (let i = 0; i < res.reddit.length; i++) {
          rtm += res.reddit[i].mention;
          rpm += res.reddit[i].positiveMention;
          rnm += res.reddit[i].negativeMention;
        }

        for (let i = 0; i < res.twitter.length; i++) {
          ttm += res.twitter[i].mention;
          tpm += res.twitter[i].positiveMention;
          tnm += res.twitter[i].negativeMention;
        }

        this.socialData = {
          rtm,
          rpm,
          rnm,
          ttm,
          tpm,
          tnm,
          symbol: res.symbol,
        };
        this.socialSentimentDone = true;
      }
    );
    // Recommendation Trends
    this.APIService.fetchCompanyRecommendationTrends(this.ticker).subscribe(
      (res) => {
        this.recommendationChartData = res;

        this.recommendationChartOptions = {
          chart: {
            type: 'column',
          },
          title: {
            text: 'Recommendation Trends',
          },
          xAxis: {
            categories: this.recommendationChartData.map((x) =>
              x.period.slice(0, 7)
            ),
          },
          yAxis: {
            min: 0,
            title: {
              text: '#analysis',
              align: 'high',
            },
          },
          credits: {
            enabled: false,
          },
          plotOptions: {
            column: {
              stacking: 'normal',
              dataLabels: {
                enabled: true,
              },
            },
          },
          series: [
            {
              name: 'Strong Buy',
              data: this.recommendationChartData.map((x) => x.strongBuy),
              type: 'column',
              color: '#1c6d37',
            },
            {
              name: 'Buy',
              data: this.recommendationChartData.map((x) => x.buy),
              type: 'column',
              color: '#19aa4d',
            },
            {
              name: 'Hold',
              data: this.recommendationChartData.map((x) => x.hold),
              type: 'column',
              color: '#9f7719',
            },
            {
              name: 'Sell',
              data: this.recommendationChartData.map((x) => x.sell),
              type: 'column',
              color: '#c2484b',
            },
            {
              name: 'Strong Sell',
              data: this.recommendationChartData.map((x) => x.strongSell),
              type: 'column',
              color: '#602426',
            },
          ],
        };
        this.recommendationDone = true;
      }
    );
    // Earnings
    this.APIService.fetchCompanyEarnings(this.ticker).subscribe((res) => {
      this.earningChartData = res;
      this.earningChartOptions = {
        chart: {
          type: 'spline',
        },
        title: {
          text: 'Historical EPS Surprises',
        },
        xAxis: {
          categories: this.earningChartData.map(
            (x) => `${x.period} \n Surprise: ${x.surprise}`
          ),
        },
        yAxis: {
          title: {
            text: 'Quarterly EPS',
          },
        },
        legend: {
          enabled: true,
        },
        plotOptions: {},
        series: [
          {
            name: 'Actual',
            data: this.earningChartData.map((x) => x.actual || 0),
            type: 'spline',
          },
          {
            name: 'Estimate',
            data: this.earningChartData.map((x) => x.estimate || 0),
            type: 'spline',
          },
        ],
      };
    });
  }

  fetchCompanyNews() {
    let toDate = new Date();
    let fromDate = new Date();
    fromDate.setDate(toDate.getDate() - 7);

    this.APIService.fetchCompanyNews(
      this.ticker,
      fromDate.toISOString().split('T')[0],
      toDate.toISOString().split('T')[0]
    ).subscribe((res) => {
      this.companyNews = res;
    });
  }

  fetchCompanyDescription() {
    this.APIService.fetchCompanyDescription(this.ticker).subscribe((res) => {
      this.companyDescription = res;
      if (this.companyDescription) {
        this.tickerExist = true;
      } else {
        this.tickerExist = false;
      }
      this.setSellBtn();
    });
  }

  createBigChart() {
    let data: Array<any[]> = [];
    let volumeData: Array<any[]> = [];
    for (let i = 0; i < this.bigChartData.timestamp.length; i++) {
      data.push([
        this.bigChartData.timestamp[i],
        this.bigChartData.close[i],
        this.bigChartData.high[i],
        this.bigChartData.low[i],
        this.bigChartData.open[i],
      ]);
      volumeData.push([
        this.bigChartData.timestamp[i],
        this.bigChartData.volume[i],
      ]);
    }
    var groupingUnits = [
      [
        'week', // unit name
        [1], // allowed multiples
      ],
      ['month', [1, 2, 3, 4, 6]],
    ];

    this.bigChartOptions = {
      series: [
        {
          type: 'candlestick',
          name: this.ticker.toUpperCase(),
          id: this.ticker,
          zIndex: 2,
          data: data,
        },
        {
          type: 'column',
          name: 'Volume',
          id: 'volume',
          data: volumeData,
          yAxis: 1,
        },
        {
          type: 'vbp',
          linkedTo: this.ticker,
          params: {
            volumeSeriesID: 'volume',
          },
          dataLabels: {
            enabled: false,
          },
          zoneLines: {
            enabled: false,
          },
        },
        {
          type: 'sma',
          linkedTo: this.ticker,
          zIndex: 1,
          marker: {
            enabled: false,
          },
        },
      ],
      title: { text: `${this.ticker.toUpperCase()} Historical` },
      subtitle: {
        text: 'With SMA and Volume by Price technical indicators',
      },
      yAxis: [
        {
          startOnTick: false,
          endOnTick: false,
          labels: {
            align: 'right',
            x: -3,
          },
          title: {
            text: 'OHLC',
          },
          height: '60%',
          lineWidth: 2,
          resize: {
            enabled: true,
          },
        },
        {
          labels: {
            align: 'right',
            x: -3,
          },
          title: {
            text: 'Volume',
          },
          top: '65%',
          height: '35%',
          offset: 0,
          lineWidth: 2,
        },
      ],
      tooltip: {
        split: true,
      },
      responsive: {
        rules: [
          {
            condition: { maxWidth: 500 },
            chartOptions: {
              plotOptions: {
                series: {
                  dataGrouping: {
                    units: [
                      [
                        'week', // unit name
                        [1], // allowed multiples
                      ],
                      ['month', [1, 2, 3, 4, 6]],
                    ],
                  },
                },
              },
            },
          },
        ],
      },
      plotOptions: {},
      rangeSelector: {
        buttons: [
          {
            type: 'month',
            count: 1,
            text: '1m',
          },
          {
            type: 'month',
            count: 3,
            text: '3m',
          },
          {
            type: 'month',
            count: 6,
            text: '6m',
          },
          {
            type: 'ytd',
            text: 'YTD',
          },
          {
            type: 'year',
            count: 1,
            text: '1y',
          },
          {
            type: 'all',
            text: 'All',
          },
        ],
        selected: 2,
      },
    };
  }

  createSmallChart() {
    let data: Array<any[]> = [];
    for (let i = 0; i < this.smallChartData.timestamp.length; i++) {
      data.push([
        this.smallChartData.timestamp[i],
        this.smallChartData.close[i],
      ]);
    }
    let color = 'red';
    if (this.change < 0) {
      color = 'red';
    } else {
      color = 'green';
    }
    this.smallChartOptions = {
      series: [
        {
          data: data,
          color: color,
          showInNavigator: true,
          name: this.ticker.toUpperCase(),
          type: 'line',
        },
      ],
      title: { text: `${this.ticker.toUpperCase()} Hourly Price Variation` },
      rangeSelector: {
        enabled: false,
      },
      navigator: {
        series: {
          type: 'area',
          color: color,
          fillOpacity: 1,
        },
      },
      xAxis: {
        labels: {
          formatter: function () {
            var time = this.value;
            let parsedDate = new Date(time).toTimeString().split(' ')[0];
            parsedDate =
              parsedDate.split(':')[0] + ':' + parsedDate.split(':')[1];
            return parsedDate;
          },
        },
        tickInterval: 3600 * 1000,
      },
    };
  }

  fetchBigChart() {
    let toTimestamp = new Date();
    let fromTimestamp = new Date();
    fromTimestamp.setFullYear(toTimestamp.getFullYear() - 1);
    fromTimestamp.setUTCDate(toTimestamp.getDay() - 1);
    this.APIService.fetchHistoricalData(
      this.ticker,
      'D',
      (fromTimestamp.getTime() / 1000).toFixed(0),
      (toTimestamp.getTime() / 1000).toFixed(0)
    ).subscribe((res) => {
      this.bigChartData = res;
      for (let i = 0; i < this.bigChartData.timestamp.length; i++) {
        this.bigChartData.timestamp[i] *= 1000;
      }
      this.bigChartDone = true;
      this.createBigChart();
    });
  }

  fetchLatestPrice() {
    this.updateSummarySub = timer(0, 15000).subscribe(() => {
      this.APIService.fetchLatestPrice(this.ticker).subscribe((res) => {
        if (res.error) {
          this.apiError = true;
          this.updateSummarySub.unsubscribe();
        }
        this.apiError = false;

        this.latestPrice = res;
        this.change = this.latestPrice.change;
        this.currentTimestamp = this.formatDate(new Date());
        this.lastTimestamp = new Date(this.latestPrice.timestamp * 1000);
        this.marketLastTimestamp = this.formatDate(this.lastTimestamp);
        let startTime = new Date(this.lastTimestamp);
        startTime.setHours(this.lastTimestamp.getHours() - 6);

        if (Date.now() - this.lastTimestamp > 60 * 1000 * 5) {
          this.marketOpen = false;
        } else {
          this.marketOpen = true;
        }

        this.APIService.fetchHistoricalData(
          this.ticker,
          '5',
          (startTime.getTime() / 1000).toFixed(0),
          (this.lastTimestamp.getTime() / 1000).toFixed(0)
        ).subscribe((res) => {
          this.smallChartData = res;
          // convert the timestamps
          for (let i = 0; i < this.smallChartData.timestamp.length; i++) {
            this.smallChartData.timestamp[i] *= 1000;
          }
          this.createSmallChart();
          this.smallChartDone = true;
        });
      });
    });
  }

  padDigits(num) {
    return num.toString().padStart(2, '0');
  }

  formatDate(date) {
    return (
      [
        date.getFullYear(),
        this.padDigits(date.getMonth() + 1),
        this.padDigits(date.getDate()),
      ].join('-') +
      ' ' +
      [
        this.padDigits(date.getHours()),
        this.padDigits(date.getMinutes()),
        this.padDigits(date.getSeconds()),
      ].join(':')
    );
  }

  ngOnDestroy() {
    this.updateSummarySub.unsubscribe();
  }
}
