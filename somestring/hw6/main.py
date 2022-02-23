from flask import Flask, render_template, request, current_app
from backend.finnhub import FinnhubClient


app = Flask(__name__)
client = FinnhubClient() 

@app.route('/')
def hello():
    """Return a friendly HTTP greeting."""
    return current_app.send_static_file('index.html')

@app.route('/get_company_tab', methods=['GET', 'POST'])
def get_company_tab(): 
    """Return stock company info"""
    stock_name = request.args.get('stock_name').upper()
    res = client.get_company_tab(stock_name)
    return res
    
@app.route('/get_stock_summary_tab', methods=['GET', 'POST'])
def get_stock_summary_tab(): 
    """Return stock summary"""
    stock_name = request.args.get('stock_name').upper()
    res = client.get_stock_summary_tab(stock_name)
    return res

@app.route('/get_stock_charts_tab', methods=['GET', 'POST'])
def get_stock_charts_tab(): 
    """Return stock chart"""
    stock_name = request.args.get('stock_name').upper()
    res = client.get_stock_charts_tab(stock_name)
    return res

@app.route('/get_latest_news_tab', methods=['GET', 'POST'])
def get_latest_news_tab(): 
    """Return stock news"""
    stock_name = request.args.get('stock_name').upper()
    res = client.get_latest_news_tab(stock_name)
    return res



if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)

