import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';

@Component({
  selector: 'app-transaction-modal',
  templateUrl: './transaction-modal.component.html',
  styleUrls: ['./transaction-modal.component.css']
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

  calculateMaxQuantity(){
    console.log(this.money);
    console.log(this.price);
    
    
    let portfolio = JSON.parse(localStorage.getItem('portfolio') || '[]');
    if (this.opt == 'sell') {
      // Max to sell
      let item = portfolio.filter((x) => x.ticker = this.ticker)[0];
      this.maxQuantity = item.quantity
    } else if (this.opt == 'buy'){
      // Max to buy
      let item = portfolio.filter((x) => x.ticker = this.ticker);
      if (item.length){       
        this.maxQuantity = Math.floor(this.money / this.price)
      }
    }
    console.log(this.maxQuantity);
  }

  checkIfValidInput(){
    // console.log(this.inputQuantity);
    // Make sure you have enough money
    if (this.opt == 'buy'){
      if (this.inputQuantity > this.maxQuantity){
        this.noMoney = true;
      }
    }
    if (this.opt == 'sell'){
      if (this.inputQuantity > this.maxQuantity){
        this.noStocks = true;
      }
    }
  }

  constructor(public modalService: NgbActiveModal) { }

  ngOnInit(): void {
    this.money = parseFloat(localStorage.getItem('money') || '0');
    console.log(this.money);
    console.log(this.price);
    
    this.calculateMaxQuantity();
    if (this.opt == 'buy'){}
  }

}
