import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { APIService } from '../apiFunctions/apiFunctions';
import { companyDescription } from '../interfaces/companyDescription';
import { historicalData } from '../interfaces/historicalData';
import { latestPrice } from '../interfaces/latestPrice';
import * as Highcharts from 'highcharts/highstock';
import { Options } from 'highcharts';

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
  marketOpen: boolean = false;
  lastTimestamp;
  marketLastTimestamp: string = '';
  companyDescription: companyDescription;
  latestPrice: latestPrice;
  smallChartData: historicalData;
  smallChartOptions: Options;
  HighCharts: typeof Highcharts = Highcharts;
  chartDone: boolean = false;

  constructor(private APIService: APIService, private route: ActivatedRoute) {}

  ngOnInit(): void {
    this.route.paramMap.subscribe((params) => {
      this.ticker = (params.get('ticker') || '').toUpperCase();
    });
    

    this.fetchCompanyDescription();
    this.fetchLatestPrice();
    this.watchListed = true;
    this.marketLastTimestamp = '2022-02-24 13:00:03';
  }

  fetchCompanyDescription() {
    this.APIService.fetchCompanyDescription(this.ticker).subscribe((res) => {
      this.companyDescription = res;
      if (this.companyDescription) {
        this.tickerExist = true;
      } else {
        this.tickerExist = false;
      }
    });
  }

  createSmallChart() {
    let data: Array<any[]> = [];
    for (let i = 0; i < this.smallChartData.timestamp.length; i++) {
      // let parsedDate = new Date(this.smallChartData.timestamp[i])
      //   .toTimeString()
      //   .split(' ')[0];
      // parsedDate =
      //   parsedDate.split(':')[0] + ':' + parsedDate.split(':')[2] + ':';

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
          // tooltip: {
          //   valueDecimals: 4,
          // },
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
            let parsedDate = new Date(time)
              .toTimeString()
              .split(' ')[0];
            // console.log(parsedDate);
            
            parsedDate =
              parsedDate.split(':')[0] + ':' + parsedDate.split(':')[1];
            return parsedDate
          },
        },
        tickInterval: 3600*1000
      },
    };
  }

  fetchLatestPrice() {
    this.APIService.fetchLatestPrice(this.ticker).subscribe((res) => {
      this.latestPrice = res;
      this.change = this.latestPrice.change;
      this.currentTimestamp = this.formatDate(new Date());
      this.lastTimestamp = new Date(this.latestPrice.timestamp * 1000);
      this.marketLastTimestamp = this.formatDate(this.lastTimestamp);
      let startTime = new Date(this.lastTimestamp);
      startTime.setHours(this.lastTimestamp.getHours() - 6);

      if (Date.now() - this.lastTimestamp > 60 * 1000) {
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
        this.chartDone = true;
        this.createSmallChart();
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
}
