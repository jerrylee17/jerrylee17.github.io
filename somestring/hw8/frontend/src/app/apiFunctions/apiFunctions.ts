import { Observable } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { latestPrice } from '../interfaces/latestPrice';
import { companyDescription } from '../interfaces/companyDescription';
import { historicalData } from '../interfaces/historicalData'
import { Autocomplete } from '../interfaces/autocomplete';

const HOST = 'http://localhost:3000';

@Injectable({
  providedIn: 'root',
})
export class APIService {
  private autoComplete = HOST + '/autocomplete';
  private latestPrice = HOST + '/getLatestPrice';
  private companyDescription = HOST + '/getCompanyDescription';
  private historicalData = HOST + '/getHistoricalData';

  constructor(private http: HttpClient) {}

  fetchAutocomplete(ticker: string): Observable<Autocomplete[]> {
    const url = `${this.autoComplete}?query=${ticker}`;
    return this.http.get<Autocomplete[]>(url);
  }

  fetchCompanyDescription(ticker: string): Observable<companyDescription> {
    const url = `${this.companyDescription}?ticker=${ticker}`;
    return this.http.get<companyDescription>(url);
  }

  fetchLatestPrice(ticker: string): Observable<latestPrice> {
    const url = `${this.latestPrice}?ticker=${ticker}`;
    return this.http.get<latestPrice>(url);
  }
  
  fetchHistoricalData(ticker, timeInterval, fromTimestamp, toTimestamp): Observable<historicalData> {
    const url = `${this.historicalData}?ticker=${ticker}&timeInterval=${timeInterval}&fromTimestamp=${fromTimestamp}&toTimestamp=${toTimestamp}`;
    return this.http.get<historicalData>(url);
  }
}

