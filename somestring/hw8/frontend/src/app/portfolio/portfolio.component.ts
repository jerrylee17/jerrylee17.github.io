import { Component, OnInit } from '@angular/core';
import { APIService } from '../apiFunctions/apiFunctions';

@Component({
  selector: 'app-portfolio',
  templateUrl: './portfolio.component.html',
  styleUrls: ['./portfolio.component.css']
})
export class PortfolioComponent implements OnInit {
  portfolioDone: boolean = false;
  isEmpty: boolean = false;

  constructor(private APIService: APIService) { }

  ngOnInit(): void {
  }

}
