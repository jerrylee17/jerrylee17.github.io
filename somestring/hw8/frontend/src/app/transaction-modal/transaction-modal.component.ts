import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';

@Component({
  selector: 'app-transaction-modal',
  templateUrl: './transaction-modal.component.html',
  styleUrls: ['./transaction-modal.component.css'],
})
export class TransactionModalComponent implements OnInit {
  @Input() public ticker: string;
  @Input() public name: string;
  @Input() public price: number;
  @Input() public opt: string; // 'Buy' or 'Sell'
  @Output() passEntry: EventEmitter<any> = new EventEmitter();
  inputQuantity: number = 0;
  maxQuantity: number = 0;
  money: number;
  noStocks: boolean = false;
  noMoney: boolean = false;

  calculateMaxQuantity() {

    let portfolio = JSON.parse(localStorage.getItem('portfolio') || '[]');
    if (this.opt == 'sell') {
      // Max to sell
      let item = portfolio.filter((x) => (x.ticker == this.ticker))[0];
      this.maxQuantity = item.quantity;
    } else if (this.opt == 'buy') {
      this.maxQuantity = Math.floor(this.money / this.price);
    }
  }

  checkIfValidInput() {
    // console.log(this.inputQuantity);
    // Make sure you have enough money
    if (this.opt == 'buy') {
      if (this.inputQuantity > this.maxQuantity) {
        this.noMoney = true;
      } else {
        this.noMoney = false;
      }
    }
    if (this.opt == 'sell') {
      if (this.inputQuantity > this.maxQuantity) {
        this.noStocks = true;
      } else {
        this.noStocks = false;
      }
    }
  }

  submitOrder(){
    // Set new money
    if (this.opt == 'buy'){
      let newMoney = this.money - this.inputQuantity * this.price
      localStorage.setItem('money', newMoney.toString())
    } else if (this.opt == 'sell'){
      let newMoney = this.money + this.inputQuantity * this.price
      localStorage.setItem('money', newMoney.toString())
    }
    
    // Set portfolio
    // Portfolio structure: {ticker, quantity, totalCost}
    let portfolio = JSON.parse(localStorage.getItem('portfolio') || '[]');    
    if (this.opt == 'buy'){
      let item = portfolio.filter((x) => (x.ticker == this.ticker))[0];
      let portfolioNoItem = portfolio.filter((x) => (x.ticker != this.ticker));
      
      let x = {
        ticker: this.ticker,
        quantity: this.inputQuantity + (item ? item.quantity : 0),
        totalCost: this.inputQuantity * this.price + (item ? item.totalCost : 0)
      }
      portfolioNoItem.push(x)
      localStorage.setItem('portfolio', JSON.stringify(portfolioNoItem));
    } else if (this.opt == 'sell'){
      let item = portfolio.filter((x) => (x.ticker == this.ticker))[0];
      let portfolioNoItem = portfolio.filter((x) => (x.ticker != this.ticker));
      
      let x = {
        ticker: this.ticker,
        quantity:  (item ? item.quantity : 0) - this.inputQuantity,
        totalCost: (item ? item.totalCost : 0) - this.inputQuantity * this.price
      }
      if (x.quantity != 0){
        portfolioNoItem.push(x)
      }
      localStorage.setItem('portfolio', JSON.stringify(portfolioNoItem));
    }
    this.modalService.close(this.ticker);
  }

  constructor(public modalService: NgbActiveModal) {}

  ngOnInit(): void {
    this.money = parseFloat(localStorage.getItem('money') || '0');

    this.calculateMaxQuantity();
    if (this.opt == 'buy') {
    }
  }
}
