import { Component, OnInit } from '@angular/core';
import { APIService } from '../apiFunctions/apiFunctions';
import { portfolio } from '../interfaces/portfolio';

@Component({
  selector: 'app-portfolio',
  templateUrl: './portfolio.component.html',
  styleUrls: ['./portfolio.component.css']
})
export class PortfolioComponent implements OnInit {
  isEmpty: boolean = true;
  portfolio: portfolio[] = [];
  money;

  constructor(private APIService: APIService) { }


  getStocks(){
    let portfolio = JSON.parse(localStorage.getItem('portfolio') || '[]');
    if (portfolio.length){
      this.isEmpty = false;
    } else {
      this.isEmpty = true;
    }
    for (let i = 0; i < portfolio.length; i++){
      this.APIService.fetchLatestPrice(portfolio[i].ticker).subscribe(
        (res) => {
          let x = {
            ticker: portfolio[i].ticker,
            name: portfolio[i].name,
            quantity: portfolio[i].quantity,
            totalCost: portfolio[i].totalCost,
            change: res.change,
            currentPrice: res.price,
            marketValue: res.price * portfolio[i].quantity
          }
          this.portfolio.push(x)
        }
      )
    }
  }

  ngOnInit(): void {
    this.money = parseFloat(localStorage.getItem('money') || '0');
    this.getStocks()
  }

}
