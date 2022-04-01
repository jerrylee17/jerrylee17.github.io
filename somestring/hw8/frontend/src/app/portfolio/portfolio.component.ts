import { Component, OnInit } from '@angular/core';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { debounceTime, Subject } from 'rxjs';
import { APIService } from '../apiFunctions/apiFunctions';
import { portfolio } from '../interfaces/portfolio';
import { TransactionModalComponent } from '../transaction-modal/transaction-modal.component';

@Component({
  selector: 'app-portfolio',
  templateUrl: './portfolio.component.html',
  styleUrls: ['./portfolio.component.css'],
})
export class PortfolioComponent implements OnInit {
  isEmpty: boolean = true;
  portfolio: portfolio[] = [];
  money;
  purchaseMessage = false;
  purchaseAlert = new Subject<string>();
  sellMessage = false;
  sellAlert = new Subject<string>();
  ticker = '';

  constructor(private APIService: APIService, private ModalService: NgbModal) {}

  getStocks() {
    let portfolio = JSON.parse(localStorage.getItem('portfolio') || '[]');
    if (portfolio.length) {
      this.isEmpty = false;
    } else {
      this.isEmpty = true;
    }
    for (let i = 0; i < portfolio.length; i++) {
      this.APIService.fetchLatestPrice(portfolio[i].ticker).subscribe((res) => {
        let x = {
          ticker: portfolio[i].ticker,
          name: portfolio[i].name,
          quantity: portfolio[i].quantity,
          totalCost: portfolio[i].totalCost,
          change: res.change,
          currentPrice: res.price,
          marketValue: res.price * portfolio[i].quantity,
        };
        this.portfolio.push(x);
      });
    }
  }

  openTransaction(ticker, name, price, opt) {
    const modalRef = this.ModalService.open(TransactionModalComponent);
    modalRef.componentInstance.ticker = ticker;
    modalRef.componentInstance.name = name;
    modalRef.componentInstance.price = price;
    modalRef.componentInstance.opt = opt;
    modalRef.result.then(() => {
      this.ticker = ticker
      if (opt == 'buy') this.purchaseAlert.next('next');
      else this.sellAlert.next('next');
      this.portfolio=[];
      this.getStocks();
    });
  }

  ngOnInit(): void {
    this.money = parseFloat(localStorage.getItem('money') || '0');
    this.getStocks();
    this.purchaseAlert.subscribe((res) => {
      if (res) this.purchaseMessage = true;
    });

    this.purchaseAlert
      .pipe(debounceTime(5000))
      .subscribe(() => {this.purchaseMessage = false; this.ticker=''});

    this.sellAlert.subscribe((res) => {
      if (res) this.sellMessage = true;
    });

    this.sellAlert
      .pipe(debounceTime(5000))
      .subscribe(() => {this.sellMessage = false; this.ticker=''});
  }
}
