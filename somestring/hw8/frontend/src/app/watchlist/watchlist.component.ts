import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { APIService } from '../apiFunctions/apiFunctions';
import { latestPrice } from '../interfaces/latestPrice';
import { watchList } from '../interfaces/watchList';

@Component({
  selector: 'app-watchlist',
  templateUrl: './watchlist.component.html',
  styleUrls: ['./watchlist.component.css']
})
export class WatchlistComponent implements OnInit {
  watchListDone: boolean = false;
  isEmpty;
  watchList: watchList[] = [];
  latestPrice: latestPrice;

  constructor(
    private APIService: APIService,
    private router: Router
  ) { }

  ngOnInit(): void {
    this.fetchWatchList();
  }

  fetchWatchList() {
    let watchList = JSON.parse(localStorage.getItem('watchlist') || '[]');
    this.isEmpty = watchList.length ? false : true;
    
    
    for (let i = 0; i < watchList.length; i++) {
      this.fetchLatestPrice(watchList[i])
    }
    this.watchListDone = true;
  }

  fetchLatestPrice(stock) {
    this.APIService.fetchLatestPrice(stock.ticker).subscribe((res) => {
      let r: watchList = ({
        ticker: stock.ticker,
        name: stock.name,
        price: res.price,
        change: res.change,
        percentChange: res.percentChange
      })
      this.watchList.push(r)
    })
  }

  redirectTo(uri: string) {
    this.router.navigateByUrl('/', { skipLocationChange: true }).then(() =>
      this.router.navigate([uri]));
  }

  redirectToStock(ticker) {
    this.redirectTo(`/search/${ticker.toUpperCase()}`);
  }

  removeFromWatchList(ticker) {
    let watchList = JSON.parse(localStorage.getItem('watchlist') || '[]');
    let x = watchList.filter((r) => r.ticker != ticker.toUpperCase());
    localStorage.setItem('watchlist', JSON.stringify(x));
    this.watchList = [];
    this.fetchWatchList();
  }
}
