import os
from datetime import datetime, date
from dateutil.relativedelta import relativedelta
from dotenv import load_dotenv
import requests
import pprint

load_dotenv()
API_KEY = os.getenv('API_KEY')

class FinnhubClient:
    def __init__(self, method=None):
        self.method=method

    def get_company_tab(self, stock_name):
        stock_company = requests.get(
            f'https://finnhub.io/api/v1/stock/profile2?symbol={stock_name}&token={API_KEY}'
        )
        try:
            stock_company_json = stock_company.json()
            # Change field names
            res = {}
            res['company_logo'] = stock_company_json['logo']
            res['company_name'] = stock_company_json['name']
            res['stock_ticker_symbol'] = stock_company_json['ticker']
            res['stock_exchange_code'] = stock_company_json['exchange']
            res['company_start_date'] = stock_company_json['ipo']
            res['category'] = stock_company_json['finnhubIndustry']
            return res
        except:
            return {'error': 'true'}
    
    def get_stock_summary_tab(self, stock_name):
        # Stock info
        stock_info = requests.get(
            f'https://finnhub.io/api/v1/quote?symbol={stock_name}&token={API_KEY}'
        )
        # Recommendations
        stock_recommendation = requests.get(
            f'https://finnhub.io/api/v1/stock/recommendation?symbol={stock_name}&token={API_KEY}'
        )
        res = {}
        try:
            stock_info_json = stock_info.json()
            # Change field names
            res['stock_ticker_symbol'] = stock_name
            res['trading_day'] = datetime.fromtimestamp(stock_info_json['t']).strftime('%d %b %Y')
            res['previous_closing_price'] = stock_info_json['pc']
            res['opening_price'] = stock_info_json['o']
            res['high_price'] = stock_info_json['h']
            res['low_price'] = stock_info_json['l']
            res['change'] = stock_info_json['d']
            res['change_percent'] = stock_info_json['dp']

            stock_recommendation_json = stock_recommendation.json()[0]
            res['strong_buy'] = stock_recommendation_json['strongBuy']
            res['buy'] = stock_recommendation_json['buy']
            res['hold'] = stock_recommendation_json['hold']
            res['sell'] = stock_recommendation_json['sell']
            res['strong_sell'] = stock_recommendation_json['strongSell']
            return res
        except:
            return {**res, 'error': 'true'}
    
    def get_stock_charts_tab(self, stock_name):
        today = date.today()
        delta = relativedelta(months=6, days=1)
        prior_date = today - delta
        today_ep = today.strftime('%s')
        prior_date_ep = prior_date.strftime('%s')
        stock_chart_info = requests.get(
            f'https://finnhub.io/api/v1/stock/candle?symbol={stock_name}&resolution=D&from={prior_date_ep}&to={today_ep}&token={API_KEY}'
        )
        try:
            stock_chart_info_json = stock_chart_info.json()
            res = {}
            # Change field names
            res['title'] = f'Stock Price {stock_name} {prior_date}'
            res['date'] = stock_chart_info_json['t']
            res['stock_price'] = stock_chart_info_json['c']
            res['volume'] = stock_chart_info_json['v']
            res['price_date'] = [(a*1000,b) for a,b in zip(res['date'], res['stock_price'])]
            res['volume_date'] = [(a*1000,b) for a,b in zip(res['date'], res['volume'])]
            res['data'] = [(a*1000,b, c) for a,b,c in zip(res['date'], res['stock_price'], res['volume'])]
            return res
        except:
            return {'error': 'true'}

    def get_latest_news_tab(self, stock_name):
        today = date.today()
        delta = relativedelta(days=30)
        prior_date = today - delta
        stock_news = requests.get(
            f'https://finnhub.io/api/v1/company-news?symbol={stock_name}&from={prior_date}&to={today}&token={API_KEY}'
        )
        try:
            stock_news_json = stock_news.json()
            res = []
            count = 0
            for news in stock_news_json:
                if news['image'] == "":
                    continue
                news_elem = {}
                news_elem['image'] = news['image']
                news_elem['title'] = news['headline']
                news_elem['date'] = datetime.fromtimestamp(news['datetime']).strftime('%d %b %Y')
                news_elem['link_to_original_post'] = news['url']
                res.append(news_elem)
                count += 1
                if count == 5: break
            return {'news': res}
        except:
            return {'error': 'true'}
  
    def get_stock_info(self, stock_name):
        try:
            company = self.get_company_tab(stock_name)
            summary = self.get_stock_summary_tab(stock_name)
            charts = self.get_stock_charts_tab(stock_name)
            news = self.get_latest_news_tab(stock_name)
            return {**company, **summary, **charts, **news}
        except:
            return {'error': 'true'}


