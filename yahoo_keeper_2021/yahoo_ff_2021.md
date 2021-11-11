

```python
import pandas as pd
import matplotlib.pyplot as plt
import time
import json
import requests
from splinter import Browser
from selenium import webdriver
from bs4 import BeautifulSoup
import numpy as np
import math
import statistics
import sys
```


```python
draft_df = pd.read_excel("C:\\Users\\mcyee\\Desktop\\yahoo_keeper_2021\\2021_Fantasy_Football_Draft.xlsx")
draft_df.head()
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>Aaron Jones</td>
      <td>RB</td>
      <td>GB</td>
      <td>27</td>
      <td>Matt</td>
      <td>BCDE</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>Jonathan Taylor</td>
      <td>RB</td>
      <td>IND</td>
      <td>64</td>
      <td>Matt</td>
      <td>E</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>Odell Beckham Jr.</td>
      <td>WR</td>
      <td>CLE</td>
      <td>5</td>
      <td>Matt</td>
      <td>E</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>Jerry Jeudy</td>
      <td>WR</td>
      <td>DEN</td>
      <td>5</td>
      <td>Matt</td>
      <td>E</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>Davante Adams</td>
      <td>WR</td>
      <td>GB</td>
      <td>60</td>
      <td>Dai</td>
      <td>ABCDE</td>
    </tr>
  </tbody>
</table>
</div>




```python
options = webdriver.ChromeOptions()
options.add_argument('--ignore-certificate-errors')
```


```python
transaction_list = []
driver = webdriver.Chrome('C:\\Users\\mcyee\\Desktop\\yahoo_keeper_2021\\chromedriver.exe')

for n in np.arange(0, 20):
    try:
        p = str(n*25)
        driver.get("https://football.fantasysports.yahoo.com/f1/597209/transactions?transactionsfilter=all&count=" + p)
        time.sleep(2)
        transaction_html = driver.page_source
        transaction_soup = BeautifulSoup(transaction_html, "html.parser")
        transaction_table = transaction_soup.findAll("table", {"class": "Table Table-mid Tst-transaction-table"})[0].findAll("tbody")[0]
        for tr in transaction_table.findAll('tr'):
            td = tr.findAll('td')
            if str(td[0]).find("Added Player") != -1 and str(td[0]).find("Dropped Player") != -1:
                player_added = td[1].find_all("a", {'target': 'sports'})[0].text
                player_added_team = td[1].find_all('span', {'class': 'F-position'})[0].text.split(' - ')[0]
                player_added_pos = td[1].find_all('span', {'class': 'F-position'})[0].text.split(' - ')[1]
                player_dropped = td[1].find_all("a", {'target': 'sports'})[1].text
                player_dropped_team = td[1].find_all('span', {'class': 'F-position'})[1].text.split(' - ')[0]
                player_dropped_pos = td[1].find_all('span', {'class': 'F-position'})[1].text.split(' - ')[1]
                manager = td[2].find_all("a", {'class': 'Tst-team-name'})[0].text
                dt_transaction = td[2].find_all("span", {'class': 'F-timestamp'})[0].text
                transaction_details = td[1].find_all('h6', {'class': 'F-shade'})[0].text
                if transaction_details.find("$") != -1:
                    transaction_cost = (transaction_details.replace('$', '').replace(' ', '').replace('Waiver', ''))
                else:
                    transaction_cost = 0    
                transaction_dict = {
                    'transaction_type': 'drop-add',
                    'player_added': player_added,
                    'player_added_team': player_added_team,
                    'player_added_pos': player_added_pos,
                    'player_dropped': player_dropped,
                    'player_dropped_team': player_dropped_team,
                    'player_dropped_pos': player_dropped_pos,
                    'ff_team': manager,
                    'transaction_time': dt_transaction,
                    'transaction_cost': transaction_cost
                }
                transaction_list.append(transaction_dict)
            elif str(td[0]).find("Dropped Player") != -1:
                player_dropped = td[1].find_all("a", {'target': 'sports'})[0].text
                player_dropped_team = td[1].find_all('span', {'class': 'F-position'})[0].text.split(' - ')[0]
                player_dropped_pos = td[1].find_all('span', {'class': 'F-position'})[0].text.split(' - ')[1]
                manager = td[2].find_all("a", {'class': 'Tst-team-name'})[0].text
                dt_transaction = td[2].find_all("span", {'class': 'F-timestamp'})[0].text
                transaction_dict = {
                    'transaction_type': 'drop',
                    'player_added': 'Bench',
                    'player_added_team': 'N/A',
                    'player_added_pos': 'N/A',
                    'player_dropped': player_dropped,
                    'player_dropped_team': player_dropped_team,
                    'player_dropped_pos': player_dropped_pos,
                    'ff_team': manager,
                    'transaction_time': dt_transaction,
                    'transaction_cost': 0
                }
                transaction_list.append(transaction_dict)
            elif str(td[0]).find("Added Player") != -1:
                player_added = td[1].find_all("a", {'target': 'sports'})[0].text
                player_added_team = td[1].find_all('span', {'class': 'F-position'})[0].text.split(' - ')[0]
                player_added_pos = td[1].find_all('span', {'class': 'F-position'})[0].text.split(' - ')[1]
                manager = td[2].find_all("a", {'class': 'Tst-team-name'})[0].text
                dt_transaction = td[2].find_all("span", {'class': 'F-timestamp'})[0].text
                transaction_details = td[1].find_all('h6', {'class': 'F-shade'})[0].text
                if transaction_details.find("$") != -1:
                    transaction_cost = (transaction_details.replace('$', '').replace(' ', '').replace('Waiver', ''))
                else:
                    transaction_cost = 0 
                transaction_dict = {
                    'transaction_type': 'add',
                    'player_added': player_added,
                    'player_added_team': player_added_team,
                    'player_added_pos': player_added_pos,
                    'player_dropped': 'Bench',
                    'player_dropped_team': "N/A",
                    'player_dropped_pos': "N/A",
                    'ff_team': manager,
                    'transaction_time': dt_transaction,
                    'transaction_cost': transaction_cost
                }
                transaction_list.append(transaction_dict)

            elif str(td[1]).find("Traded to") != -1:
                manager = td[2].find_all("span", {'class': 'Grid-u'})[0].find_all("a")[0].text
                dt_transaction = td[2].find_all("span", {'class': 'F-timestamp'})[0].text
                adds = td[0].find_all('a', {'target': 'sports'})
                for a in range(len(adds)):
                    player_added = td[0].find_all("a", {'target': 'sports'})[a].text
                    player_added_team = td[0].find_all('span', {'class': 'F-position'})[a].text.split(' - ')[0]
                    player_added_pos = td[0].find_all('span', {'class': 'F-position'})[a].text.split(' - ')[1]
                    transaction_dict = {
                        'transaction_type': 'trade',
                        'player_added': player_added,
                        'player_added_team': player_added_team,
                        'player_added_pos': player_added_pos,
                        'player_dropped': 'N/A',
                        'player_dropped_team': "N/A",
                        'player_dropped_pos': "N/A",
                        'ff_team': manager,
                        'transaction_time': dt_transaction,
                        'transaction_cost': 0
                    }
                    transaction_list.append(transaction_dict)
            elif str(td[2]).find("Traded to") != -1:
                manager = td[3].find_all("span", {'class': 'Grid-u'})[0].find_all("a")[0].text
                dt_transaction = td[3].find_all("span", {'class': 'F-timestamp'})[0].text
                adds = td[1].find_all('a', {'target': 'sports'})
                for a in range(len(adds)):
                    player_added = td[1].find_all("a", {'target': 'sports'})[a].text
                    player_added_team = td[1].find_all('span', {'class': 'F-position'})[a].text.split(' - ')[0]
                    player_added_pos = td[1].find_all('span', {'class': 'F-position'})[a].text.split(' - ')[1]
                    transaction_dict = {
                        'transaction_type': 'trade',
                        'player_added': player_added,
                        'player_added_team': player_added_team,
                        'player_added_pos': player_added_pos,
                        'player_dropped': 'N/A',
                        'player_dropped_team': "N/A",
                        'player_dropped_pos': "N/A",
                        'ff_team': manager,
                        'transaction_time': dt_transaction,
                        'transaction_cost': 0
                    }
                    transaction_list.append(transaction_dict)
    except:
        pass

driver.quit()
transaction_df = pd.DataFrame(transaction_list)
transaction_df.head()
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>ff_team</th>
      <th>player_added</th>
      <th>player_added_pos</th>
      <th>player_added_team</th>
      <th>player_dropped</th>
      <th>player_dropped_pos</th>
      <th>player_dropped_team</th>
      <th>transaction_cost</th>
      <th>transaction_time</th>
      <th>transaction_type</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>folklore</td>
      <td>Los Angeles</td>
      <td>DEF</td>
      <td>LAC</td>
      <td>Philadelphia</td>
      <td>DEF</td>
      <td>Phi</td>
      <td>0</td>
      <td>Nov 10, 11:02 am</td>
      <td>drop-add</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Odellta Variant</td>
      <td>Le'Veon Bell</td>
      <td>RB</td>
      <td>Bal</td>
      <td>Dan Arnold</td>
      <td>TE</td>
      <td>Jax</td>
      <td>0</td>
      <td>Nov 10, 8:52 am</td>
      <td>drop-add</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Odellta Variant</td>
      <td>Travis Etienne</td>
      <td>RB</td>
      <td>Jax</td>
      <td>Boston Scott</td>
      <td>RB</td>
      <td>Phi</td>
      <td>0</td>
      <td>Nov 10, 8:51 am</td>
      <td>drop-add</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Zeke and Ye Shall Find</td>
      <td>Rhamondre Stevenson</td>
      <td>RB</td>
      <td>NE</td>
      <td>Carlos Hyde</td>
      <td>RB</td>
      <td>Jax</td>
      <td>0</td>
      <td>Nov 10, 6:43 am</td>
      <td>drop-add</td>
    </tr>
    <tr>
      <th>4</th>
      <td>folklore</td>
      <td>Philadelphia</td>
      <td>DEF</td>
      <td>Phi</td>
      <td>San Francisco</td>
      <td>DEF</td>
      <td>SF</td>
      <td>0</td>
      <td>Nov 10, 5:00 am</td>
      <td>drop-add</td>
    </tr>
  </tbody>
</table>
</div>




```python
manager_list = []
for m in list(set(transaction_df['ff_team'])):
    manager = input("Which player is the manager for " + m + "?")
    manager_dict = {
        'ff_team': m,
        'manager': manager
    }
    manager_list.append(manager_dict)
manager_df = pd.DataFrame(manager_list)
manager_df
    
```

    Which player is the manager for Raider Bae?Jake
    Which player is the manager for Tiz the Law?Dai
    Which player is the manager for folklore?Ron
    Which player is the manager for Pop Drop and Lockett?Evan
    Which player is the manager for Me So Fourney?Joel
    Which player is the manager for G?Jiwei
    Which player is the manager for Odellta Variant?Matt
    Which player is the manager for Nags?Ryan
    Which player is the manager for Mediocre Team?Rajiv
    Which player is the manager for Boswell that Ends Well?Sean
    Which player is the manager for Chi ShingT's Team?Chi Shing
    Which player is the manager for Zeke and Ye Shall Find?Doug
    




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>ff_team</th>
      <th>manager</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Raider Bae</td>
      <td>Jake</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Tiz the Law</td>
      <td>Dai</td>
    </tr>
    <tr>
      <th>2</th>
      <td>folklore</td>
      <td>Ron</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Pop Drop and Lockett</td>
      <td>Evan</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Me So Fourney</td>
      <td>Joel</td>
    </tr>
    <tr>
      <th>5</th>
      <td>G</td>
      <td>Jiwei</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Odellta Variant</td>
      <td>Matt</td>
    </tr>
    <tr>
      <th>7</th>
      <td>Nags</td>
      <td>Ryan</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Mediocre Team</td>
      <td>Rajiv</td>
    </tr>
    <tr>
      <th>9</th>
      <td>Boswell that Ends Well</td>
      <td>Sean</td>
    </tr>
    <tr>
      <th>10</th>
      <td>Chi ShingT's Team</td>
      <td>Chi Shing</td>
    </tr>
    <tr>
      <th>11</th>
      <td>Zeke and Ye Shall Find</td>
      <td>Doug</td>
    </tr>
  </tbody>
</table>
</div>




```python
transaction_df = pd.DataFrame(transaction_list)
transaction_df['transaction_time'] = "2020 " + transaction_df['transaction_time']
transaction_df['transaction_time'] = pd.to_datetime(transaction_df['transaction_time'], format="%Y %b %d, %I:%M %p")
transaction_df = transaction_df.sort_values(by='transaction_time').reset_index(drop=True)
transaction_df = transaction_df.merge(manager_df, on='ff_team', how='left')
transaction_df.to_csv("C:\\Users\\mcyee\\Desktop\\yahoo_keeper_2021\\2021_Fantasy_Football_Transactions.csv")
transaction_df.head()
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>ff_team</th>
      <th>player_added</th>
      <th>player_added_pos</th>
      <th>player_added_team</th>
      <th>player_dropped</th>
      <th>player_dropped_pos</th>
      <th>player_dropped_team</th>
      <th>transaction_cost</th>
      <th>transaction_time</th>
      <th>transaction_type</th>
      <th>manager</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Pop Drop and Lockett</td>
      <td>Ty'Son Williams</td>
      <td>RB</td>
      <td>Bal</td>
      <td>Los Angeles</td>
      <td>DEF</td>
      <td>LAC</td>
      <td>7</td>
      <td>2020-08-30 00:09:00</td>
      <td>drop-add</td>
      <td>Evan</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Me So Fourney</td>
      <td>Jermar Jefferson</td>
      <td>RB</td>
      <td>Det</td>
      <td>Kirk Cousins</td>
      <td>QB</td>
      <td>Min</td>
      <td>5</td>
      <td>2020-08-30 00:09:00</td>
      <td>drop-add</td>
      <td>Joel</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Odellta Variant</td>
      <td>Nelson Agholor</td>
      <td>WR</td>
      <td>NE</td>
      <td>Todd Gurley II</td>
      <td>RB</td>
      <td>Atl</td>
      <td>0</td>
      <td>2020-08-30 00:09:00</td>
      <td>drop-add</td>
      <td>Matt</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Boswell that Ends Well</td>
      <td>Sterling Shepard</td>
      <td>WR</td>
      <td>NYG</td>
      <td>Russell Gage</td>
      <td>WR</td>
      <td>Atl</td>
      <td>0</td>
      <td>2020-08-30 00:10:00</td>
      <td>drop-add</td>
      <td>Sean</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Boswell that Ends Well</td>
      <td>Tony Jones Jr.</td>
      <td>RB</td>
      <td>NO</td>
      <td>Latavius Murray</td>
      <td>RB</td>
      <td>Bal</td>
      <td>0</td>
      <td>2020-08-30 00:13:00</td>
      <td>drop-add</td>
      <td>Sean</td>
    </tr>
  </tbody>
</table>
</div>




```python
transaction_df.columns
```




    Index(['ff_team', 'player_added', 'player_added_pos', 'player_added_team',
           'player_dropped', 'player_dropped_pos', 'player_dropped_team',
           'transaction_cost', 'transaction_time', 'transaction_type', 'manager'],
          dtype='object')




```python
draft_df = pd.read_excel("C:\\Users\\mcyee\\Desktop\\yahoo_keeper_2021\\2021_Fantasy_Football_Draft.xlsx")
draft_df.head()

for i, r in transaction_df.iterrows():
#     print(i, r['transaction_type'], r['player_added'], r['player_added_team'], r['player_dropped'], r['player_dropped_team'])
    if r['transaction_type'] == 'drop-add':
        draft_row_n = draft_df[(draft_df['player_name'] == r['player_dropped']) & (draft_df['player_team'] == r['player_dropped_team'])]
        draft_df.at[draft_row_n.index[0], 'player_name'] = r['player_added']
        draft_df.at[draft_row_n.index[0], 'player_team'] = r['player_added_team']
        draft_df.at[draft_row_n.index[0], 'player_position'] = r['player_added_pos']
        draft_df.at[draft_row_n.index[0], 'salary'] = r['transaction_cost']
        draft_df = draft_df.reset_index(drop=True)
    elif r['transaction_type'] == 'drop':
        draft_row_n = draft_df[(draft_df['player_name'] == r['player_dropped']) & (draft_df['player_team'] == r['player_dropped_team'])]
        draft_df = draft_df.drop([draft_row_n.index[0]]).reset_index(drop=True)
    elif r['transaction_type'] == 'add':
        draft_df = draft_df.append({'pick': 0, 
                         'player_name': r['player_added'], 
                         'player_position': r['player_added_pos'], 
                         'player_team': r['player_added_team'],
                         'salary': r['transaction_cost'],
                         'manager': r['manager'],
                         'keeper_code': ''
                        }, ignore_index=True)
        draft_df = draft_df.reset_index(drop=True)
    elif r['transaction_type'] == 'trade':
        draft_row_n = draft_df[(draft_df['player_name'] == r['player_added']) & (draft_df['player_team'] == r['player_added_team'])]
        draft_df.at[draft_row_n.index[0], 'manager'] = r['manager']
        draft_df.reset_index(drop=True)
draft_df = draft_df.sort_values(by=['manager', 'salary']).reset_index(drop=True)
```


```python
draft_df.to_csv('C:\\Users\\mcyee\\Desktop\\yahoo_keeper_2021\\yahoo_keeper_2021.csv')
```


```python
draft_df[draft_df['manager'] == 'Chi Shing']
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>96</td>
      <td>C.J. Uzomah</td>
      <td>TE</td>
      <td>Cin</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1</th>
      <td>132</td>
      <td>Emmanuel Sanders</td>
      <td>WR</td>
      <td>Buf</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2</th>
      <td>136</td>
      <td>Khalil Herbert</td>
      <td>RB</td>
      <td>Chi</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>3</th>
      <td>157</td>
      <td>Van Jefferson Jr.</td>
      <td>WR</td>
      <td>LAR</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>4</th>
      <td>145</td>
      <td>Matt Gay</td>
      <td>K</td>
      <td>LAR</td>
      <td>1</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>5</th>
      <td>86</td>
      <td>Los Angeles</td>
      <td>DEF</td>
      <td>LAR</td>
      <td>4</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>6</th>
      <td>129</td>
      <td>Christian Kirk</td>
      <td>WR</td>
      <td>Ari</td>
      <td>8</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>7</th>
      <td>126</td>
      <td>DeVonta Smith</td>
      <td>WR</td>
      <td>Phi</td>
      <td>12</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>8</th>
      <td>71</td>
      <td>Melvin Gordon III</td>
      <td>RB</td>
      <td>Den</td>
      <td>21</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>9</th>
      <td>10</td>
      <td>CeeDee Lamb</td>
      <td>WR</td>
      <td>DAL</td>
      <td>23</td>
      <td>Chi Shing</td>
      <td>E</td>
    </tr>
    <tr>
      <th>10</th>
      <td>11</td>
      <td>Patrick Mahomes</td>
      <td>QB</td>
      <td>KC</td>
      <td>24</td>
      <td>Chi Shing</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>11</th>
      <td>91</td>
      <td>Tyler Higbee</td>
      <td>TE</td>
      <td>LAR</td>
      <td>25</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>12</th>
      <td>82</td>
      <td>Kareem Hunt</td>
      <td>RB</td>
      <td>Cle</td>
      <td>32</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>13</th>
      <td>65</td>
      <td>Chris Godwin</td>
      <td>WR</td>
      <td>TB</td>
      <td>57</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>14</th>
      <td>9</td>
      <td>Joe Mixon</td>
      <td>RB</td>
      <td>CIN</td>
      <td>72</td>
      <td>Chi Shing</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>15</th>
      <td>46</td>
      <td>Adrian Peterson</td>
      <td>RB</td>
      <td>Ten</td>
      <td>37</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Dai']
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>16</th>
      <td>8</td>
      <td>Jamal Agnew</td>
      <td>WR</td>
      <td>Jax</td>
      <td>0</td>
      <td>Dai</td>
      <td>E</td>
    </tr>
    <tr>
      <th>17</th>
      <td>119</td>
      <td>Derrick Gore</td>
      <td>RB</td>
      <td>KC</td>
      <td>0</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>18</th>
      <td>127</td>
      <td>Greg Joseph</td>
      <td>K</td>
      <td>Min</td>
      <td>0</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>19</th>
      <td>138</td>
      <td>Kadarius Toney</td>
      <td>WR</td>
      <td>NYG</td>
      <td>0</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>20</th>
      <td>139</td>
      <td>Zach Ertz</td>
      <td>TE</td>
      <td>Ari</td>
      <td>0</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>21</th>
      <td>169</td>
      <td>Rashaad Penny</td>
      <td>RB</td>
      <td>Sea</td>
      <td>0</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>22</th>
      <td>182</td>
      <td>Zack Moss</td>
      <td>RB</td>
      <td>Buf</td>
      <td>0</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>23</th>
      <td>162</td>
      <td>Michael Carter</td>
      <td>RB</td>
      <td>NYJ</td>
      <td>3</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>24</th>
      <td>122</td>
      <td>Sony Michel</td>
      <td>RB</td>
      <td>LAR</td>
      <td>9</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>25</th>
      <td>40</td>
      <td>Josh Allen</td>
      <td>QB</td>
      <td>Buf</td>
      <td>23</td>
      <td>Dai</td>
      <td>E</td>
    </tr>
    <tr>
      <th>26</th>
      <td>7</td>
      <td>DJ Moore</td>
      <td>WR</td>
      <td>Car</td>
      <td>26</td>
      <td>Dai</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>27</th>
      <td>66</td>
      <td>Kyle Pitts</td>
      <td>TE</td>
      <td>Atl</td>
      <td>40</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>28</th>
      <td>5</td>
      <td>Davante Adams</td>
      <td>WR</td>
      <td>GB</td>
      <td>60</td>
      <td>Dai</td>
      <td>ABCDE</td>
    </tr>
    <tr>
      <th>29</th>
      <td>59</td>
      <td>Najee Harris</td>
      <td>RB</td>
      <td>Pit</td>
      <td>78</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>30</th>
      <td>125</td>
      <td>Russell Gage</td>
      <td>WR</td>
      <td>Atl</td>
      <td>3</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>31</th>
      <td>170</td>
      <td>Arizona</td>
      <td>DEF</td>
      <td>Ari</td>
      <td>4</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Doug']
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>32</th>
      <td>148</td>
      <td>Buffalo</td>
      <td>DEF</td>
      <td>Buf</td>
      <td>0</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>33</th>
      <td>159</td>
      <td>Michael Badgley</td>
      <td>K</td>
      <td>Ind</td>
      <td>0</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>34</th>
      <td>185</td>
      <td>Chuba Hubbard</td>
      <td>RB</td>
      <td>Car</td>
      <td>0</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>35</th>
      <td>0</td>
      <td>Rhamondre Stevenson</td>
      <td>RB</td>
      <td>NE</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>36</th>
      <td>0</td>
      <td>Rondale Moore</td>
      <td>WR</td>
      <td>Ari</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>37</th>
      <td>168</td>
      <td>Jakobi Meyers</td>
      <td>WR</td>
      <td>NE</td>
      <td>1</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>38</th>
      <td>27</td>
      <td>Justin Herbert</td>
      <td>QB</td>
      <td>SD</td>
      <td>5</td>
      <td>Doug</td>
      <td>E</td>
    </tr>
    <tr>
      <th>39</th>
      <td>29</td>
      <td>James Robinson</td>
      <td>RB</td>
      <td>JAX</td>
      <td>5</td>
      <td>Doug</td>
      <td>E</td>
    </tr>
    <tr>
      <th>40</th>
      <td>97</td>
      <td>A.J. Green</td>
      <td>WR</td>
      <td>Ari</td>
      <td>5</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>41</th>
      <td>147</td>
      <td>Mike Gesicki</td>
      <td>TE</td>
      <td>Mia</td>
      <td>6</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>42</th>
      <td>134</td>
      <td>Tim Patrick</td>
      <td>WR</td>
      <td>Den</td>
      <td>7</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>43</th>
      <td>15</td>
      <td>George Kittle</td>
      <td>TE</td>
      <td>SF</td>
      <td>27</td>
      <td>Doug</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>44</th>
      <td>67</td>
      <td>Julio Jones</td>
      <td>WR</td>
      <td>Ten</td>
      <td>42</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>45</th>
      <td>49</td>
      <td>Ezekiel Elliott</td>
      <td>RB</td>
      <td>Dal</td>
      <td>87</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>46</th>
      <td>57</td>
      <td>DeAndre Hopkins</td>
      <td>WR</td>
      <td>Ari</td>
      <td>90</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>47</th>
      <td>0</td>
      <td>Devontae Booker</td>
      <td>RB</td>
      <td>NYG</td>
      <td>43</td>
      <td>Doug</td>
      <td></td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Evan']
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>48</th>
      <td>73</td>
      <td>Darrel Williams</td>
      <td>RB</td>
      <td>KC</td>
      <td>0</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>49</th>
      <td>121</td>
      <td>Jimmy Garoppolo</td>
      <td>QB</td>
      <td>SF</td>
      <td>0</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>50</th>
      <td>133</td>
      <td>Jared Cook</td>
      <td>TE</td>
      <td>LAC</td>
      <td>0</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>51</th>
      <td>152</td>
      <td>Matt Prater</td>
      <td>K</td>
      <td>Ari</td>
      <td>2</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>52</th>
      <td>153</td>
      <td>Darnell Mooney</td>
      <td>WR</td>
      <td>Chi</td>
      <td>4</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>53</th>
      <td>116</td>
      <td>Michael Gallup</td>
      <td>WR</td>
      <td>Dal</td>
      <td>11</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>54</th>
      <td>128</td>
      <td>Jarvis Landry</td>
      <td>WR</td>
      <td>Cle</td>
      <td>15</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>55</th>
      <td>85</td>
      <td>Tyler Boyd</td>
      <td>WR</td>
      <td>Cin</td>
      <td>18</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>56</th>
      <td>77</td>
      <td>Damien Harris</td>
      <td>RB</td>
      <td>NE</td>
      <td>23</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>57</th>
      <td>41</td>
      <td>Kyler Murray</td>
      <td>QB</td>
      <td>ARI</td>
      <td>24</td>
      <td>Evan</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>58</th>
      <td>39</td>
      <td>Antonio Gibson</td>
      <td>RB</td>
      <td>WAS</td>
      <td>27</td>
      <td>Evan</td>
      <td>E</td>
    </tr>
    <tr>
      <th>59</th>
      <td>42</td>
      <td>Tyler Lockett</td>
      <td>WR</td>
      <td>SEA</td>
      <td>32</td>
      <td>Evan</td>
      <td>BCDE</td>
    </tr>
    <tr>
      <th>60</th>
      <td>6</td>
      <td>Miles Sanders</td>
      <td>RB</td>
      <td>Phi</td>
      <td>41</td>
      <td>Evan</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>61</th>
      <td>163</td>
      <td>Evan Engram</td>
      <td>TE</td>
      <td>NYG</td>
      <td>2</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>62</th>
      <td>140</td>
      <td>Jeremy McNichols</td>
      <td>RB</td>
      <td>Ten</td>
      <td>22</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>63</th>
      <td>89</td>
      <td>Baltimore</td>
      <td>DEF</td>
      <td>Bal</td>
      <td>3</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Jake']
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>64</th>
      <td>25</td>
      <td>Michael Thomas</td>
      <td>WR</td>
      <td>NO</td>
      <td>0</td>
      <td>Jake</td>
      <td>E</td>
    </tr>
    <tr>
      <th>65</th>
      <td>83</td>
      <td>DeSean Jackson</td>
      <td>WR</td>
      <td>LV</td>
      <td>0</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>66</th>
      <td>101</td>
      <td>Jamison Crowder</td>
      <td>WR</td>
      <td>NYJ</td>
      <td>0</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>67</th>
      <td>146</td>
      <td>Donovan Peoples-Jones</td>
      <td>WR</td>
      <td>Cle</td>
      <td>0</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>68</th>
      <td>106</td>
      <td>Justin Tucker</td>
      <td>K</td>
      <td>Bal</td>
      <td>2</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>69</th>
      <td>112</td>
      <td>Cole Beasley</td>
      <td>WR</td>
      <td>Buf</td>
      <td>2</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>70</th>
      <td>74</td>
      <td>James Conner</td>
      <td>RB</td>
      <td>Ari</td>
      <td>16</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>71</th>
      <td>24</td>
      <td>Cooper Kupp</td>
      <td>WR</td>
      <td>LAR</td>
      <td>26</td>
      <td>Jake</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>72</th>
      <td>80</td>
      <td>Mike Davis</td>
      <td>RB</td>
      <td>Atl</td>
      <td>33</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>73</th>
      <td>76</td>
      <td>Josh Jacobs</td>
      <td>RB</td>
      <td>LV</td>
      <td>38</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>74</th>
      <td>64</td>
      <td>Lamar Jackson</td>
      <td>QB</td>
      <td>Bal</td>
      <td>47</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>75</th>
      <td>62</td>
      <td>Mike Evans</td>
      <td>WR</td>
      <td>TB</td>
      <td>48</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>76</th>
      <td>23</td>
      <td>Darren Waller</td>
      <td>TE</td>
      <td>LV</td>
      <td>56</td>
      <td>Jake</td>
      <td>E</td>
    </tr>
    <tr>
      <th>77</th>
      <td>84</td>
      <td>Malik Turner</td>
      <td>WR</td>
      <td>Dal</td>
      <td>1</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>78</th>
      <td>151</td>
      <td>Indianapolis</td>
      <td>DEF</td>
      <td>Ind</td>
      <td>1</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>79</th>
      <td>26</td>
      <td>Devonta Freeman</td>
      <td>RB</td>
      <td>Bal</td>
      <td>6</td>
      <td>Jake</td>
      <td>E</td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Jiwei']
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>80</th>
      <td>28</td>
      <td>Alex Collins</td>
      <td>RB</td>
      <td>Sea</td>
      <td>0</td>
      <td>Jiwei</td>
      <td>E</td>
    </tr>
    <tr>
      <th>81</th>
      <td>100</td>
      <td>Chase McLaughlin</td>
      <td>K</td>
      <td>Cle</td>
      <td>0</td>
      <td>Jiwei</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>82</th>
      <td>131</td>
      <td>Kendrick Bourne</td>
      <td>WR</td>
      <td>NE</td>
      <td>0</td>
      <td>Jiwei</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>83</th>
      <td>149</td>
      <td>Brandon Bolden</td>
      <td>RB</td>
      <td>NE</td>
      <td>0</td>
      <td>Jiwei</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>84</th>
      <td>160</td>
      <td>D'Ernest Johnson</td>
      <td>RB</td>
      <td>Cle</td>
      <td>0</td>
      <td>Jiwei</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>85</th>
      <td>137</td>
      <td>Cleveland</td>
      <td>DEF</td>
      <td>Cle</td>
      <td>1</td>
      <td>Jiwei</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>86</th>
      <td>72</td>
      <td>Jalen Hurts</td>
      <td>QB</td>
      <td>Phi</td>
      <td>7</td>
      <td>Jiwei</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>87</th>
      <td>117</td>
      <td>Marvin Jones Jr.</td>
      <td>WR</td>
      <td>Jax</td>
      <td>7</td>
      <td>Jiwei</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>88</th>
      <td>45</td>
      <td>Justin Jefferson</td>
      <td>WR</td>
      <td>Min</td>
      <td>9</td>
      <td>Jiwei</td>
      <td>E</td>
    </tr>
    <tr>
      <th>89</th>
      <td>141</td>
      <td>Alexander Mattison</td>
      <td>RB</td>
      <td>Min</td>
      <td>11</td>
      <td>Jiwei</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>90</th>
      <td>144</td>
      <td>AJ Dillon</td>
      <td>RB</td>
      <td>GB</td>
      <td>11</td>
      <td>Jiwei</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>91</th>
      <td>92</td>
      <td>Antonio Brown</td>
      <td>WR</td>
      <td>TB</td>
      <td>15</td>
      <td>Jiwei</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>92</th>
      <td>87</td>
      <td>Mark Andrews</td>
      <td>TE</td>
      <td>Bal</td>
      <td>31</td>
      <td>Jiwei</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>93</th>
      <td>43</td>
      <td>Chris Carson</td>
      <td>RB</td>
      <td>SEA</td>
      <td>46</td>
      <td>Jiwei</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>94</th>
      <td>44</td>
      <td>Calvin Ridley</td>
      <td>WR</td>
      <td>Atl</td>
      <td>48</td>
      <td>Jiwei</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>95</th>
      <td>47</td>
      <td>Keenan Allen</td>
      <td>WR</td>
      <td>LAC</td>
      <td>51</td>
      <td>Jiwei</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Joel']
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>96</th>
      <td>51</td>
      <td>Derek Carr</td>
      <td>QB</td>
      <td>LV</td>
      <td>0</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>97</th>
      <td>165</td>
      <td>Leonard Fournette</td>
      <td>RB</td>
      <td>TB</td>
      <td>0</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>98</th>
      <td>177</td>
      <td>Tyler Bass</td>
      <td>K</td>
      <td>Buf</td>
      <td>0</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>99</th>
      <td>79</td>
      <td>Rashod Bateman</td>
      <td>WR</td>
      <td>Bal</td>
      <td>4</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>100</th>
      <td>33</td>
      <td>TJ Hockinson</td>
      <td>TE</td>
      <td>Det</td>
      <td>10</td>
      <td>Joel</td>
      <td>E</td>
    </tr>
    <tr>
      <th>101</th>
      <td>93</td>
      <td>Brandin Cooks</td>
      <td>WR</td>
      <td>Hou</td>
      <td>11</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>102</th>
      <td>104</td>
      <td>Deebo Samuel</td>
      <td>WR</td>
      <td>SF</td>
      <td>13</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>103</th>
      <td>34</td>
      <td>Aaron Rodgers</td>
      <td>QB</td>
      <td>GB</td>
      <td>15</td>
      <td>Joel</td>
      <td>E</td>
    </tr>
    <tr>
      <th>104</th>
      <td>32</td>
      <td>Darrell Henderson Jr.</td>
      <td>RB</td>
      <td>LAR</td>
      <td>16</td>
      <td>Joel</td>
      <td>E</td>
    </tr>
    <tr>
      <th>105</th>
      <td>81</td>
      <td>Tee Higgins</td>
      <td>WR</td>
      <td>Cin</td>
      <td>28</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>106</th>
      <td>78</td>
      <td>Diontae Johnson</td>
      <td>WR</td>
      <td>Pit</td>
      <td>37</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>107</th>
      <td>68</td>
      <td>D'Andre Swift</td>
      <td>RB</td>
      <td>Det</td>
      <td>43</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>108</th>
      <td>31</td>
      <td>David Montgomery</td>
      <td>RB</td>
      <td>Chi</td>
      <td>54</td>
      <td>Joel</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>109</th>
      <td>130</td>
      <td>Pittsburgh</td>
      <td>DEF</td>
      <td>Pit</td>
      <td>3</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>110</th>
      <td>0</td>
      <td>Kenyan Drake</td>
      <td>RB</td>
      <td>LV</td>
      <td>4</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>111</th>
      <td>61</td>
      <td>Pat Freiermuth</td>
      <td>TE</td>
      <td>Pit</td>
      <td>5</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Matt']
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>112</th>
      <td>98</td>
      <td>Miami</td>
      <td>DEF</td>
      <td>Mia</td>
      <td>0</td>
      <td>Matt</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>113</th>
      <td>109</td>
      <td>Travis Etienne</td>
      <td>RB</td>
      <td>Jax</td>
      <td>0</td>
      <td>Matt</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>114</th>
      <td>120</td>
      <td>Jordan Howard</td>
      <td>RB</td>
      <td>Phi</td>
      <td>0</td>
      <td>Matt</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>115</th>
      <td>150</td>
      <td>Le'Veon Bell</td>
      <td>RB</td>
      <td>Bal</td>
      <td>0</td>
      <td>Matt</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>116</th>
      <td>156</td>
      <td>T.Y. Hilton</td>
      <td>WR</td>
      <td>Ind</td>
      <td>0</td>
      <td>Matt</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>117</th>
      <td>190</td>
      <td>Brandon Aiyuk</td>
      <td>WR</td>
      <td>SF</td>
      <td>0</td>
      <td>Matt</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>118</th>
      <td>108</td>
      <td>Harrison Butker</td>
      <td>K</td>
      <td>KC</td>
      <td>2</td>
      <td>Matt</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>119</th>
      <td>3</td>
      <td>Odell Beckham Jr.</td>
      <td>WR</td>
      <td>CLE</td>
      <td>5</td>
      <td>Matt</td>
      <td>E</td>
    </tr>
    <tr>
      <th>120</th>
      <td>4</td>
      <td>Jerry Jeudy</td>
      <td>WR</td>
      <td>DEN</td>
      <td>5</td>
      <td>Matt</td>
      <td>E</td>
    </tr>
    <tr>
      <th>121</th>
      <td>107</td>
      <td>Matthew Stafford</td>
      <td>QB</td>
      <td>LAR</td>
      <td>10</td>
      <td>Matt</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>122</th>
      <td>99</td>
      <td>Noah Fant</td>
      <td>TE</td>
      <td>Den</td>
      <td>17</td>
      <td>Matt</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>123</th>
      <td>102</td>
      <td>Kenny Golladay</td>
      <td>WR</td>
      <td>NYG</td>
      <td>21</td>
      <td>Matt</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>124</th>
      <td>1</td>
      <td>Aaron Jones</td>
      <td>RB</td>
      <td>GB</td>
      <td>27</td>
      <td>Matt</td>
      <td>BCDE</td>
    </tr>
    <tr>
      <th>125</th>
      <td>2</td>
      <td>Jonathan Taylor</td>
      <td>RB</td>
      <td>IND</td>
      <td>64</td>
      <td>Matt</td>
      <td>E</td>
    </tr>
    <tr>
      <th>126</th>
      <td>56</td>
      <td>Tyreek Hill</td>
      <td>WR</td>
      <td>KC</td>
      <td>90</td>
      <td>Matt</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>127</th>
      <td>12</td>
      <td>Allen Robinson II</td>
      <td>WR</td>
      <td>Chi</td>
      <td>21</td>
      <td>Matt</td>
      <td>E</td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Rajiv']
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>128</th>
      <td>70</td>
      <td>Eno Benjamin</td>
      <td>RB</td>
      <td>Ari</td>
      <td>0</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>129</th>
      <td>75</td>
      <td>Deonte Harris</td>
      <td>WR</td>
      <td>NO</td>
      <td>0</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>130</th>
      <td>113</td>
      <td>Denver</td>
      <td>DEF</td>
      <td>Den</td>
      <td>0</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>131</th>
      <td>143</td>
      <td>Nyheim Hines</td>
      <td>RB</td>
      <td>Ind</td>
      <td>0</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>132</th>
      <td>166</td>
      <td>Younghoe Koo</td>
      <td>K</td>
      <td>Atl</td>
      <td>0</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>133</th>
      <td>187</td>
      <td>Hunter Henry</td>
      <td>TE</td>
      <td>NE</td>
      <td>0</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>134</th>
      <td>179</td>
      <td>Devin Singletary</td>
      <td>RB</td>
      <td>Buf</td>
      <td>1</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>135</th>
      <td>171</td>
      <td>Marquise Brown</td>
      <td>WR</td>
      <td>Bal</td>
      <td>2</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>136</th>
      <td>192</td>
      <td>Marquez Callaway</td>
      <td>WR</td>
      <td>NO</td>
      <td>3</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>137</th>
      <td>184</td>
      <td>Hunter Renfrow</td>
      <td>WR</td>
      <td>LV</td>
      <td>6</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>138</th>
      <td>95</td>
      <td>Ryan Tannehill</td>
      <td>QB</td>
      <td>Ten</td>
      <td>9</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>139</th>
      <td>22</td>
      <td>Terry McLaurin</td>
      <td>WR</td>
      <td>WAS</td>
      <td>49</td>
      <td>Rajiv</td>
      <td>E</td>
    </tr>
    <tr>
      <th>140</th>
      <td>69</td>
      <td>Adam Thielen</td>
      <td>WR</td>
      <td>Min</td>
      <td>49</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>141</th>
      <td>21</td>
      <td>Derrick Henry</td>
      <td>RB</td>
      <td>TEN</td>
      <td>56</td>
      <td>Rajiv</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>142</th>
      <td>48</td>
      <td>Saquon Barkley</td>
      <td>RB</td>
      <td>NYG</td>
      <td>79</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>143</th>
      <td>105</td>
      <td>Kenneth Gainwell</td>
      <td>RB</td>
      <td>Phi</td>
      <td>23</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Ron']
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>144</th>
      <td>123</td>
      <td>Joe Burrow</td>
      <td>QB</td>
      <td>Cin</td>
      <td>0</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>145</th>
      <td>135</td>
      <td>Cordarrelle Patterson</td>
      <td>WR,RB</td>
      <td>Atl</td>
      <td>0</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>146</th>
      <td>158</td>
      <td>Los Angeles</td>
      <td>DEF</td>
      <td>LAC</td>
      <td>0</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>147</th>
      <td>172</td>
      <td>Dawson Knox</td>
      <td>TE</td>
      <td>Buf</td>
      <td>4</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>148</th>
      <td>20</td>
      <td>Myles Gaskin</td>
      <td>RB</td>
      <td>MIA</td>
      <td>11</td>
      <td>Ron</td>
      <td>E</td>
    </tr>
    <tr>
      <th>149</th>
      <td>17</td>
      <td>DK Metcalf</td>
      <td>WR</td>
      <td>SEA</td>
      <td>12</td>
      <td>Ron</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>150</th>
      <td>111</td>
      <td>Dallas Goedert</td>
      <td>TE</td>
      <td>Phi</td>
      <td>13</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>151</th>
      <td>110</td>
      <td>Corey Davis</td>
      <td>WR</td>
      <td>NYJ</td>
      <td>18</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>152</th>
      <td>50</td>
      <td>Chase Edmonds</td>
      <td>RB</td>
      <td>Ari</td>
      <td>19</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>153</th>
      <td>63</td>
      <td>Ja'Marr Chase</td>
      <td>WR</td>
      <td>Cin</td>
      <td>19</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>154</th>
      <td>18</td>
      <td>Austin Ekeler</td>
      <td>RB</td>
      <td>SD</td>
      <td>22</td>
      <td>Ron</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>155</th>
      <td>103</td>
      <td>Courtland Sutton</td>
      <td>WR</td>
      <td>Den</td>
      <td>23</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>156</th>
      <td>60</td>
      <td>Russell Wilson</td>
      <td>QB</td>
      <td>Sea</td>
      <td>28</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>157</th>
      <td>115</td>
      <td>Eli Mitchell</td>
      <td>RB</td>
      <td>SF</td>
      <td>43</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>158</th>
      <td>53</td>
      <td>Christian McCaffrey</td>
      <td>RB</td>
      <td>Car</td>
      <td>125</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>159</th>
      <td>0</td>
      <td>Nick Folk</td>
      <td>K</td>
      <td>NE</td>
      <td>1</td>
      <td>Ron</td>
      <td></td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Ryan']
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>160</th>
      <td>38</td>
      <td>New England</td>
      <td>DEF</td>
      <td>NE</td>
      <td>0</td>
      <td>Ryan</td>
      <td>E</td>
    </tr>
    <tr>
      <th>161</th>
      <td>114</td>
      <td>Daniel Carlson</td>
      <td>K</td>
      <td>LV</td>
      <td>0</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>162</th>
      <td>173</td>
      <td>J.K. Dobbins</td>
      <td>RB</td>
      <td>Bal</td>
      <td>0</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>163</th>
      <td>175</td>
      <td>Rob Gronkowski</td>
      <td>TE</td>
      <td>TB</td>
      <td>1</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>164</th>
      <td>174</td>
      <td>Tony Pollard</td>
      <td>RB</td>
      <td>Dal</td>
      <td>2</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>165</th>
      <td>176</td>
      <td>Jamaal Williams</td>
      <td>RB</td>
      <td>Det</td>
      <td>2</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>166</th>
      <td>124</td>
      <td>Tampa Bay</td>
      <td>DEF</td>
      <td>TB</td>
      <td>4</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>167</th>
      <td>37</td>
      <td>Chase Claypool</td>
      <td>WR</td>
      <td>PIT</td>
      <td>5</td>
      <td>Ryan</td>
      <td>E</td>
    </tr>
    <tr>
      <th>168</th>
      <td>118</td>
      <td>Laviska Shenault Jr.</td>
      <td>WR</td>
      <td>Jax</td>
      <td>10</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>169</th>
      <td>88</td>
      <td>Tom Brady</td>
      <td>QB</td>
      <td>TB</td>
      <td>13</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>170</th>
      <td>36</td>
      <td>Nick Chubb</td>
      <td>RB</td>
      <td>CLE</td>
      <td>24</td>
      <td>Ryan</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>171</th>
      <td>181</td>
      <td>Michael Pittman Jr.</td>
      <td>WR</td>
      <td>Ind</td>
      <td>26</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>172</th>
      <td>55</td>
      <td>Robert Woods</td>
      <td>WR</td>
      <td>LAR</td>
      <td>40</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>173</th>
      <td>35</td>
      <td>Travis Kelce</td>
      <td>TE</td>
      <td>KC</td>
      <td>73</td>
      <td>Ryan</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>174</th>
      <td>52</td>
      <td>Dalvin Cook</td>
      <td>RB</td>
      <td>Min</td>
      <td>111</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>175</th>
      <td>161</td>
      <td>Carson Wentz</td>
      <td>QB</td>
      <td>Ind</td>
      <td>11</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Sean']
```




<div>
<style>
    .dataframe thead tr:only-child th {
        text-align: right;
    }

    .dataframe thead th {
        text-align: left;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pick</th>
      <th>player_name</th>
      <th>player_position</th>
      <th>player_team</th>
      <th>salary</th>
      <th>manager</th>
      <th>keeper_code</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>176</th>
      <td>164</td>
      <td>Elijah Moore</td>
      <td>WR</td>
      <td>NYJ</td>
      <td>0</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>177</th>
      <td>167</td>
      <td>Mark Ingram II</td>
      <td>RB</td>
      <td>NO</td>
      <td>0</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>178</th>
      <td>178</td>
      <td>Chris Boswell</td>
      <td>K</td>
      <td>Pit</td>
      <td>0</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>179</th>
      <td>16</td>
      <td>Dak Prescott</td>
      <td>QB</td>
      <td>DAL</td>
      <td>5</td>
      <td>Sean</td>
      <td>E</td>
    </tr>
    <tr>
      <th>180</th>
      <td>154</td>
      <td>Jaylen Waddle</td>
      <td>WR</td>
      <td>Mia</td>
      <td>5</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>181</th>
      <td>188</td>
      <td>Dalton Schultz</td>
      <td>TE</td>
      <td>Dal</td>
      <td>9</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>182</th>
      <td>90</td>
      <td>Mike Williams</td>
      <td>WR</td>
      <td>LAC</td>
      <td>13</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>183</th>
      <td>14</td>
      <td>AJ Brown</td>
      <td>WR</td>
      <td>TEN</td>
      <td>18</td>
      <td>Sean</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>184</th>
      <td>94</td>
      <td>Javonte Williams</td>
      <td>RB</td>
      <td>Den</td>
      <td>25</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>185</th>
      <td>13</td>
      <td>Alvin Kamara</td>
      <td>RB</td>
      <td>NO</td>
      <td>36</td>
      <td>Sean</td>
      <td>BCDE</td>
    </tr>
    <tr>
      <th>186</th>
      <td>54</td>
      <td>Amari Cooper</td>
      <td>WR</td>
      <td>Dal</td>
      <td>41</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>187</th>
      <td>19</td>
      <td>Stefon Diggs</td>
      <td>WR</td>
      <td>Buf</td>
      <td>46</td>
      <td>Sean</td>
      <td>E</td>
    </tr>
    <tr>
      <th>188</th>
      <td>58</td>
      <td>Clyde Edwards-Helaire</td>
      <td>RB</td>
      <td>KC</td>
      <td>68</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>189</th>
      <td>189</td>
      <td>Logan Thomas</td>
      <td>TE</td>
      <td>Was</td>
      <td>3</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>190</th>
      <td>183</td>
      <td>J.D. McKissic</td>
      <td>RB</td>
      <td>Was</td>
      <td>33</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>191</th>
      <td>142</td>
      <td>Tennessee</td>
      <td>DEF</td>
      <td>Ten</td>
      <td>6</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>


