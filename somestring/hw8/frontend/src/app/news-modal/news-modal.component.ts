import { Component, Input, OnInit } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { companyNews } from '../interfaces/companyNews';

@Component({
  selector: 'app-news-modal',
  templateUrl: './news-modal.component.html',
  styleUrls: ['./news-modal.component.css'],
})
export class NewsModalComponent implements OnInit {
  @Input() public news: companyNews;
  fbLink: string;

  constructor(public modalService: NgbActiveModal) {}

  ngOnInit(): void {
    this.fbLink =
      'https://www.facebook.com/sharer/sharer.php?u=' +
      encodeURIComponent(this.news.url) +
      '&amp;src=sdkpreparse';
  }

  openLink(url: string) {
    window.open(url, '_blank');
  }
}
