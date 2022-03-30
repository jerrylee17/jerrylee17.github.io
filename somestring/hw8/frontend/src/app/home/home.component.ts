import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormControl, FormGroup } from '@angular/forms';
import { Router } from '@angular/router';
import { debounceTime, Observable, switchMap, tap } from 'rxjs';
import { map, startWith, finalize } from 'rxjs/operators';
import { APIService } from '../apiFunctions/apiFunctions';
import { Autocomplete } from '../interfaces/autocomplete';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css'],
})
export class HomeComponent implements OnInit {
  options: Autocomplete[] = [];
  stockForm: FormControl = new FormControl();
  isLoading: boolean = false;

  constructor(
    private APIService: APIService,
    private router: Router
  ) {
  }

  ngOnInit(): void {
    this.stockForm.valueChanges
      .pipe(
        debounceTime(300),
        tap(() => (this.isLoading = true))
      )
      .subscribe((options) => {
        this.APIService.fetchAutocomplete(options).subscribe((val) => {
          console.log(val);
          
          this.options = val;
          this.isLoading = false;
        });
      });
  }

  onSubmit(ticker) {
    console.log(ticker);
    this.router.navigateByUrl(`/search/${ticker.toUpperCase()}`);
    this.stockForm.reset();
  }

  onClear() {
    this.stockForm.setValue('');
  }

  setTicker(company){
    if (company){
      return company.displaySymbol;
    }
  }
}
