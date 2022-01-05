

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

for n in np.arange(0, 40):
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
      <td>Amon The Stars</td>
      <td>D'Ernest Johnson</td>
      <td>RB</td>
      <td>Cle</td>
      <td>San Francisco</td>
      <td>DEF</td>
      <td>SF</td>
      <td>0</td>
      <td>Jan 2, 4:34 pm</td>
      <td>drop-add</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Zeke and Ye Shall Find</td>
      <td>Deonte Harris</td>
      <td>WR</td>
      <td>NO</td>
      <td>Emmanuel Sanders</td>
      <td>WR</td>
      <td>Buf</td>
      <td>0</td>
      <td>Jan 2, 9:24 am</td>
      <td>drop-add</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Zeke and Ye Shall Find</td>
      <td>Trey Sermon</td>
      <td>RB</td>
      <td>SF</td>
      <td>Philadelphia</td>
      <td>DEF</td>
      <td>Phi</td>
      <td>0</td>
      <td>Jan 2, 9:08 am</td>
      <td>drop-add</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Zeke and Ye Shall Find</td>
      <td>Gabriel Davis</td>
      <td>WR</td>
      <td>Buf</td>
      <td>Tyler Johnson</td>
      <td>WR</td>
      <td>TB</td>
      <td>0</td>
      <td>Dec 31, 3:46 pm</td>
      <td>drop-add</td>
    </tr>
    <tr>
      <th>4</th>
      <td>folklore</td>
      <td>Josh Gordon</td>
      <td>WR</td>
      <td>KC</td>
      <td>Joshua Palmer</td>
      <td>WR</td>
      <td>LAC</td>
      <td>0</td>
      <td>Dec 31, 1:02 pm</td>
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
    Which player is the manager for Waddle It Be??Sean
    Which player is the manager for Zeke and Ye Shall Find?Doug
    Which player is the manager for Got Taylor Need Swift?Matt
    Which player is the manager for Chi ShingT's Team?Chi Shing
    Which player is the manager for Amon The Stars?Joel
    Which player is the manager for Tiz the Law?Dai
    Which player is the manager for folklore?Ron
    Which player is the manager for Pop Drop and Lockett?Evan
    Which player is the manager for Nags?Ryan
    Which player is the manager for G?Jiwei
    Which player is the manager for Sacko?Rajiv
    




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
      <td>Waddle It Be?</td>
      <td>Sean</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Zeke and Ye Shall Find</td>
      <td>Doug</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Got Taylor Need Swift</td>
      <td>Matt</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Chi ShingT's Team</td>
      <td>Chi Shing</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Amon The Stars</td>
      <td>Joel</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Tiz the Law</td>
      <td>Dai</td>
    </tr>
    <tr>
      <th>7</th>
      <td>folklore</td>
      <td>Ron</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Pop Drop and Lockett</td>
      <td>Evan</td>
    </tr>
    <tr>
      <th>9</th>
      <td>Nags</td>
      <td>Ryan</td>
    </tr>
    <tr>
      <th>10</th>
      <td>G</td>
      <td>Jiwei</td>
    </tr>
    <tr>
      <th>11</th>
      <td>Sacko</td>
      <td>Rajiv</td>
    </tr>
  </tbody>
</table>
</div>




```python
transaction_df = pd.DataFrame(transaction_list)
for i, r in transaction_df.iterrows():
    if r['transaction_time'].find('Jan') != -1:
        transaction_df.at[i, 'transaction_time'] = "2022 " + r['transaction_time']
    else:
        transaction_df.at[i, 'transaction_time'] = "2021 " + r['transaction_time']
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
      <td>2021-08-30 00:09:00</td>
      <td>drop-add</td>
      <td>Evan</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Amon The Stars</td>
      <td>Jermar Jefferson</td>
      <td>RB</td>
      <td>Det</td>
      <td>Kirk Cousins</td>
      <td>QB</td>
      <td>Min</td>
      <td>5</td>
      <td>2021-08-30 00:09:00</td>
      <td>drop-add</td>
      <td>Joel</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Got Taylor Need Swift</td>
      <td>Nelson Agholor</td>
      <td>WR</td>
      <td>NE</td>
      <td>Todd Gurley II</td>
      <td>RB</td>
      <td>Atl</td>
      <td>0</td>
      <td>2021-08-30 00:09:00</td>
      <td>drop-add</td>
      <td>Matt</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Waddle It Be?</td>
      <td>Sterling Shepard</td>
      <td>WR</td>
      <td>NYG</td>
      <td>Russell Gage</td>
      <td>WR</td>
      <td>Atl</td>
      <td>0</td>
      <td>2021-08-30 00:10:00</td>
      <td>drop-add</td>
      <td>Sean</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Waddle It Be?</td>
      <td>Tony Jones Jr.</td>
      <td>RB</td>
      <td>NO</td>
      <td>Latavius Murray</td>
      <td>RB</td>
      <td>Bal</td>
      <td>0</td>
      <td>2021-08-30 00:13:00</td>
      <td>drop-add</td>
      <td>Sean</td>
    </tr>
  </tbody>
</table>
</div>




```python
transaction_df[24:25]
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
      <th>24</th>
      <td>Raider Bae</td>
      <td>New England</td>
      <td>DEF</td>
      <td>NE</td>
      <td>Phillip Lindsay</td>
      <td>RB</td>
      <td>Mia</td>
      <td>0</td>
      <td>2021-09-05 12:19:00</td>
      <td>drop-add</td>
      <td>Jake</td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df = pd.read_excel("C:\\Users\\mcyee\\Desktop\\yahoo_keeper_2021\\2021_Fantasy_Football_Draft.xlsx")
draft_df
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
    <tr>
      <th>5</th>
      <td>6</td>
      <td>Miles Sanders</td>
      <td>RB</td>
      <td>Phi</td>
      <td>41</td>
      <td>Dai</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>6</th>
      <td>7</td>
      <td>DJ Moore</td>
      <td>WR</td>
      <td>Car</td>
      <td>26</td>
      <td>Dai</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>7</th>
      <td>8</td>
      <td>Zack Moss</td>
      <td>RB</td>
      <td>Buf</td>
      <td>16</td>
      <td>Dai</td>
      <td>E</td>
    </tr>
    <tr>
      <th>8</th>
      <td>9</td>
      <td>Joe Mixon</td>
      <td>RB</td>
      <td>CIN</td>
      <td>72</td>
      <td>Chi Shing</td>
      <td>CDE</td>
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
      <td>12</td>
      <td>Robby Anderson</td>
      <td>WR</td>
      <td>Car</td>
      <td>6</td>
      <td>Chi Shing</td>
      <td>E</td>
    </tr>
    <tr>
      <th>12</th>
      <td>13</td>
      <td>Alvin Kamara</td>
      <td>RB</td>
      <td>NO</td>
      <td>36</td>
      <td>Sean</td>
      <td>BCDE</td>
    </tr>
    <tr>
      <th>13</th>
      <td>14</td>
      <td>AJ Brown</td>
      <td>WR</td>
      <td>TEN</td>
      <td>18</td>
      <td>Sean</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>14</th>
      <td>15</td>
      <td>George Kittle</td>
      <td>TE</td>
      <td>SF</td>
      <td>27</td>
      <td>Sean</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>15</th>
      <td>16</td>
      <td>Dak Prescott</td>
      <td>QB</td>
      <td>DAL</td>
      <td>5</td>
      <td>Sean</td>
      <td>E</td>
    </tr>
    <tr>
      <th>16</th>
      <td>17</td>
      <td>DK Metcalf</td>
      <td>WR</td>
      <td>SEA</td>
      <td>12</td>
      <td>Ron</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>17</th>
      <td>18</td>
      <td>Austin Ekeler</td>
      <td>RB</td>
      <td>SD</td>
      <td>22</td>
      <td>Ron</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>18</th>
      <td>19</td>
      <td>Stefon Diggs</td>
      <td>WR</td>
      <td>Buf</td>
      <td>46</td>
      <td>Ron</td>
      <td>E</td>
    </tr>
    <tr>
      <th>19</th>
      <td>20</td>
      <td>Myles Gaskin</td>
      <td>RB</td>
      <td>MIA</td>
      <td>11</td>
      <td>Ron</td>
      <td>E</td>
    </tr>
    <tr>
      <th>20</th>
      <td>21</td>
      <td>Derrick Henry</td>
      <td>RB</td>
      <td>TEN</td>
      <td>56</td>
      <td>Rajiv</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>21</th>
      <td>22</td>
      <td>Terry McLaurin</td>
      <td>WR</td>
      <td>WAS</td>
      <td>49</td>
      <td>Rajiv</td>
      <td>E</td>
    </tr>
    <tr>
      <th>22</th>
      <td>23</td>
      <td>Darren Waller</td>
      <td>TE</td>
      <td>LV</td>
      <td>56</td>
      <td>Jake</td>
      <td>E</td>
    </tr>
    <tr>
      <th>23</th>
      <td>24</td>
      <td>Cooper Kupp</td>
      <td>WR</td>
      <td>LAR</td>
      <td>26</td>
      <td>Jake</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>24</th>
      <td>25</td>
      <td>Jonnu Smith</td>
      <td>TE</td>
      <td>NE</td>
      <td>8</td>
      <td>Jake</td>
      <td>E</td>
    </tr>
    <tr>
      <th>25</th>
      <td>26</td>
      <td>Henry Ruggs III</td>
      <td>WR</td>
      <td>LV</td>
      <td>5</td>
      <td>Jake</td>
      <td>E</td>
    </tr>
    <tr>
      <th>26</th>
      <td>27</td>
      <td>Justin Herbert</td>
      <td>QB</td>
      <td>SD</td>
      <td>5</td>
      <td>Doug</td>
      <td>E</td>
    </tr>
    <tr>
      <th>27</th>
      <td>28</td>
      <td>J.K. Dobbins</td>
      <td>RB</td>
      <td>Bal</td>
      <td>8</td>
      <td>Doug</td>
      <td>E</td>
    </tr>
    <tr>
      <th>28</th>
      <td>29</td>
      <td>James Robinson</td>
      <td>RB</td>
      <td>JAX</td>
      <td>5</td>
      <td>Doug</td>
      <td>E</td>
    </tr>
    <tr>
      <th>29</th>
      <td>30</td>
      <td>Robert Tonyan</td>
      <td>TE</td>
      <td>GB</td>
      <td>8</td>
      <td>Doug</td>
      <td>E</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>162</th>
      <td>163</td>
      <td>Los Angeles</td>
      <td>DEF</td>
      <td>LAC</td>
      <td>1</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>163</th>
      <td>164</td>
      <td>Emmanuel Sanders</td>
      <td>WR</td>
      <td>Buf</td>
      <td>1</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>164</th>
      <td>165</td>
      <td>Gabriel Davis</td>
      <td>WR</td>
      <td>Buf</td>
      <td>2</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>165</th>
      <td>166</td>
      <td>Wil Lutz</td>
      <td>K</td>
      <td>NO</td>
      <td>1</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>166</th>
      <td>167</td>
      <td>Russell Gage</td>
      <td>WR</td>
      <td>Atl</td>
      <td>2</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>167</th>
      <td>168</td>
      <td>Jakobi Meyers</td>
      <td>WR</td>
      <td>NE</td>
      <td>1</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>168</th>
      <td>169</td>
      <td>Elijah Moore</td>
      <td>WR</td>
      <td>NYJ</td>
      <td>2</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>169</th>
      <td>170</td>
      <td>Hunter Henry</td>
      <td>TE</td>
      <td>NE</td>
      <td>3</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>170</th>
      <td>171</td>
      <td>Marquise Brown</td>
      <td>WR</td>
      <td>Bal</td>
      <td>2</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>171</th>
      <td>172</td>
      <td>Gerald Everett</td>
      <td>TE</td>
      <td>Sea</td>
      <td>2</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>172</th>
      <td>173</td>
      <td>Gus Edwards</td>
      <td>RB</td>
      <td>Bal</td>
      <td>3</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>173</th>
      <td>174</td>
      <td>Tony Pollard</td>
      <td>RB</td>
      <td>Dal</td>
      <td>2</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>174</th>
      <td>175</td>
      <td>Rob Gronkowski</td>
      <td>TE</td>
      <td>TB</td>
      <td>1</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>175</th>
      <td>176</td>
      <td>Jamaal Williams</td>
      <td>RB</td>
      <td>Det</td>
      <td>2</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>176</th>
      <td>177</td>
      <td>John Brown</td>
      <td>WR</td>
      <td>Jax</td>
      <td>1</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>177</th>
      <td>178</td>
      <td>Justice Hill</td>
      <td>RB</td>
      <td>Bal</td>
      <td>1</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>178</th>
      <td>179</td>
      <td>Devin Singletary</td>
      <td>RB</td>
      <td>Buf</td>
      <td>1</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>179</th>
      <td>180</td>
      <td>Juwan Johnson</td>
      <td>WR,TE</td>
      <td>NO</td>
      <td>1</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>180</th>
      <td>181</td>
      <td>T.Y. Hilton</td>
      <td>WR</td>
      <td>Ind</td>
      <td>1</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>181</th>
      <td>182</td>
      <td>Rhamondre Stevenson</td>
      <td>RB</td>
      <td>NE</td>
      <td>1</td>
      <td>Dai</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>182</th>
      <td>183</td>
      <td>Latavius Murray</td>
      <td>RB</td>
      <td>Bal</td>
      <td>1</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>183</th>
      <td>184</td>
      <td>Ryan Fitzpatrick</td>
      <td>QB</td>
      <td>Was</td>
      <td>1</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>184</th>
      <td>185</td>
      <td>Terrace Marshall Jr.</td>
      <td>WR</td>
      <td>Car</td>
      <td>1</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>185</th>
      <td>186</td>
      <td>Chuba Hubbard</td>
      <td>RB</td>
      <td>Car</td>
      <td>1</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>186</th>
      <td>187</td>
      <td>Cole Kmet</td>
      <td>TE</td>
      <td>Chi</td>
      <td>1</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>187</th>
      <td>188</td>
      <td>Carlos Hyde</td>
      <td>RB</td>
      <td>Jax</td>
      <td>1</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>188</th>
      <td>189</td>
      <td>Brandon McManus</td>
      <td>K</td>
      <td>Den</td>
      <td>1</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>189</th>
      <td>190</td>
      <td>DeVante Parker</td>
      <td>WR</td>
      <td>Mia</td>
      <td>1</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>190</th>
      <td>191</td>
      <td>Nyheim Hines</td>
      <td>RB</td>
      <td>Ind</td>
      <td>1</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>191</th>
      <td>192</td>
      <td>New Orleans</td>
      <td>DEF</td>
      <td>NO</td>
      <td>1</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
<p>192 rows × 7 columns</p>
</div>




```python
draft_df = pd.read_excel("C:\\Users\\mcyee\\Desktop\\yahoo_keeper_2021\\2021_Fantasy_Football_Draft.xlsx")
draft_df.head()

for i, r in transaction_df.iterrows():
    print(i, r['transaction_type'], r['player_added'], r['player_added_team'], r['player_dropped'], r['player_dropped_team'])
    if r['transaction_type'] == 'drop-add':
        draft_row_n = draft_df[(draft_df['player_name'] == r['player_dropped'])]
        draft_df.at[draft_row_n.index[0], 'player_name'] = r['player_added']
        draft_df.at[draft_row_n.index[0], 'player_team'] = r['player_added_team']
        draft_df.at[draft_row_n.index[0], 'player_position'] = r['player_added_pos']
        draft_df.at[draft_row_n.index[0], 'salary'] = r['transaction_cost']
        draft_df.at[draft_row_n.index[0], 'keeper_code'] = ''
        draft_df = draft_df.reset_index(drop=True)
    elif r['transaction_type'] == 'drop':
        draft_row_n = draft_df[(draft_df['player_name'] == r['player_dropped'])]
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
        draft_row_n = draft_df[(draft_df['player_name'] == r['player_added'])]
        draft_df.at[draft_row_n.index[0], 'manager'] = r['manager']
        draft_df.reset_index(drop=True)
draft_df = draft_df.sort_values(by=['manager', 'salary']).reset_index(drop=True)
```

    0 drop-add Ty'Son Williams Bal Los Angeles LAC
    1 drop-add Jermar Jefferson Det Kirk Cousins Min
    2 drop-add Nelson Agholor NE Todd Gurley II Atl
    3 drop-add Sterling Shepard NYG Russell Gage Atl
    4 drop-add Tony Jones Jr. NO Latavius Murray Bal
    5 drop-add Ty Johnson NYJ Leonard Fournette TB
    6 drop-add Tyrell Williams Det Allen Lazard GB
    7 drop-add Aldrick Rosas Det Wil Lutz NO
    8 drop-add Tua Tagovailoa Mia Cole Kmet Chi
    9 drop-add Rodrigo Blankenship Ind Aldrick Rosas Det
    10 drop-add Jalen Reagor Phi John Brown Jax
    11 drop-add Devontae Booker NYG New Orleans NO
    12 drop-add Chris Evans Cin Sam Darnold Car
    13 drop-add Miami Mia New England NE
    14 drop-add Kenneth Gainwell Phi Justice Hill Bal
    15 drop-add Daniel Carlson LV Nick Folk NE
    16 drop-add Todd Gurley II Atl Juwan Johnson NO
    17 drop-add Jason Myers Sea Brandon McManus Den
    18 drop-add Bryan Edwards LV J.K. Dobbins Bal
    19 drop-add Rondale Moore Ari Tony Jones Jr. NO
    20 drop-add Mac Jones NE Deshaun Watson Hou
    21 drop-add Wayne Gallman Jr. Min Todd Gurley II Atl
    22 drop-add Russell Gage Atl T.Y. Hilton Ind
    23 drop-add Jameis Winston NO Carson Wentz Ind
    24 drop-add New England NE Phillip Lindsay Mia
    25 drop-add Tyler Conklin Min Irv Smith Jr. Min
    26 drop-add Juwan Johnson NO Joe Burrow Cin
    27 drop-add Latavius Murray Bal Justin Fields Chi
    28 drop-add Tony Jones Jr. NO Wayne Gallman Jr. Min
    29 drop-add J.J. Taylor NE Indianapolis Ind
    30 drop-add Justin Jackson LAC Jermar Jefferson Det
    31 drop-add Leonard Fournette TB Gabriel Davis Buf
    32 drop-add Giovani Bernard TB Juwan Johnson NO
    33 drop-add Le'Veon Bell TB Latavius Murray Bal
    34 drop-add Latavius Murray Bal Gus Edwards Bal
    35 drop-add Juwan Johnson NO Giovani Bernard TB
    36 drop-add Marquez Valdes-Scantling GB Emmanuel Sanders Buf
    37 drop-add Green Bay GB Curtis Samuel Was
    38 drop-add Matt Breida Buf Zack Moss Buf
    39 drop-add Darrel Williams KC Matt Breida Buf
    40 drop-add Sammy Watkins Bal Justin Jackson LAC
    41 drop-add Eli Mitchell SF Ty Johnson NYJ
    42 drop-add Mark Ingram II NO Tevin Coleman NYJ
    43 drop-add Christian Kirk Ari Jamison Crowder NYJ
    44 drop-add Larry Rountree III LAC J.J. Taylor NE
    45 drop-add Tim Patrick Den Parris Campbell Ind
    46 drop-add Zach Pascal Ind Terrace Marshall Jr. Car
    47 drop-add New Orleans NO Miami Mia
    48 drop-add Justin Fields Chi Amon-Ra St. Brown Det
    49 drop-add K.J. Osborn Min Mac Jones NE
    50 drop-add Arizona Ari Buffalo Buf
    51 drop-add Van Jefferson Jr. LAR Darrel Williams KC
    52 drop-add Matt Prater Ari Jason Sanders Mia
    53 drop-add JaMycal Hasty SF Ryan Fitzpatrick Was
    54 drop-add Jared Goff Det Chris Evans Cin
    55 drop-add Joe Burrow Cin Jared Goff Det
    56 drop-add Chicago Chi Carolina Car
    57 drop-add Emmanuel Sanders Buf Cam Akers LAR
    58 drop-add Terrace Marshall Jr. Car Chuba Hubbard Car
    59 drop-add Buffalo Buf Chicago Chi
    60 drop-add Jared Cook LAC Evan Engram NYG
    61 drop-add Quintez Cephus Det Tyrell Williams Det
    62 drop-add Peyton Barber LV Travis Etienne Jax
    63 drop-add Cordarrelle Patterson Atl Michael Pittman Jr. Ind
    64 drop-add Cole Kmet Chi Gerald Everett Sea
    65 drop-add Phillip Lindsay Mia Raheem Mostert SF
    66 trade Ronald Jones II TB N/A N/A
    67 trade Robby Anderson Car N/A N/A
    68 trade Emmanuel Sanders Buf N/A N/A
    69 trade Kareem Hunt Cle N/A N/A
    70 drop-add Nick Folk NE Rodrigo Blankenship Ind
    71 drop-add Zack Moss Buf Rhamondre Stevenson NE
    72 drop-add Jared Goff Det K.J. Osborn Min
    73 drop-add Devonta Freeman Bal Carlos Hyde Jax
    74 drop-add Seattle Sea Hunter Henry NE
    75 drop-add Amon-Ra St. Brown Det Devonta Freeman Bal
    76 drop-add Chris Evans Cin Peyton Barber LV
    77 drop-add Cedrick Wilson Dal Amon-Ra St. Brown Det
    78 drop-add Greg Joseph Min Matt Prater Ari
    79 drop-add Kirk Cousins Min Seattle Sea
    80 drop-add Brandon McManus Den Nick Folk NE
    81 drop-add Jamison Crowder NYJ Terrace Marshall Jr. Car
    82 drop-add Alexander Mattison Min Green Bay GB
    83 drop-add J.D. McKissic Was Marquez Valdes-Scantling GB
    84 drop-add K.J. Osborn Min Jared Goff Det
    85 drop-add Michael Pittman Jr. Ind Russell Gage Atl
    86 drop-add Carolina Car New Orleans NO
    87 drop-add Daniel Jones NYG Joe Burrow Cin
    88 drop-add Las Vegas LV Washington Was
    89 drop-add Chuba Hubbard Car Zach Pascal Ind
    90 drop-add Jacques Patrick Car Jamison Crowder NYJ
    91 drop-add Demetric Felton Cle Marquez Callaway NO
    92 drop-add Nick Folk NE Ryan Succop TB
    93 drop-add Matt Prater Ari Jason Myers Sea
    94 drop-add Josh Gordon KC Nelson Agholor NE
    95 drop-add Derek Carr LV Tua Tagovailoa Mia
    96 drop-add Ty Johnson NYJ Matt Ryan Atl
    97 drop-add Zach Pascal Ind Jarvis Landry Cle
    98 drop-add Darrel Williams KC Jacques Patrick Car
    99 drop-add Kerryon Johnson Phi Trevor Lawrence Jax
    100 drop-add Trey Lance SF Elijah Moore NYJ
    101 drop-add Quez Watkins Phi JaMycal Hasty SF
    102 trade Ryan Tannehill Ten N/A N/A
    103 trade Will Fuller V Mia N/A N/A
    104 trade James Conner Ari N/A N/A
    105 trade DeVante Parker Mia N/A N/A
    106 drop-add Cincinnati Cin Baltimore Bal
    107 drop-add Chase McLaughlin Cle Matt Prater Ari
    108 drop-add Marlon Mack Ind Kerryon Johnson Phi
    109 drop-add Washington Was Arizona Ari
    110 drop-add New Orleans NO Pittsburgh Pit
    111 drop-add Peyton Barber LV James White NE
    112 drop-add Tennessee Ten Carolina Car
    113 drop-add Dawson Knox Buf Cole Kmet Chi
    114 drop-add A.J. Green Ari Juwan Johnson NO
    115 drop-add Hunter Renfrow LV Quez Watkins Phi
    116 drop-add Dalton Schultz Dal Cedrick Wilson Dal
    117 drop-add Marquez Callaway NO Devontae Booker NYG
    118 drop-add Rashod Bateman Bal Darrel Williams KC
    119 drop-add Green Bay GB San Francisco SF
    120 drop-add Indianapolis Ind Las Vegas LV
    121 drop-add Jeremy McNichols Ten Sammy Watkins Bal
    122 drop-add J.J. Taylor NE Jeremy McNichols Ten
    123 drop-add Rhamondre Stevenson NE Trey Lance SF
    124 drop-add Nick Westbrook-Ikhine Ten DJ Chark Jr. Jax
    125 drop-add Cole Kmet Chi Nick Folk NE
    126 drop-add Hunter Henry NE Cole Kmet Chi
    127 drop-add Ryan Succop TB Hunter Henry NE
    128 drop-add Curtis Samuel Was Jalen Reagor Phi
    129 drop-add Cameron Brate TB Rashod Bateman Bal
    130 drop-add Benny Snell Jr. Pit Tony Jones Jr. NO
    131 drop-add Nick Folk NE Ryan Succop TB
    132 drop Bench N/A J.J. Taylor NE
    133 add Justin Jackson LAC Bench N/A
    134 drop-add Atlanta Atl Tennessee Ten
    135 drop-add Sam Darnold Car New Orleans NO
    136 drop-add Dallas Dal Cincinnati Cin
    137 drop-add Kadarius Toney NYG Mecole Hardman KC
    138 drop-add Trey Lance SF Rhamondre Stevenson NE
    139 drop-add Matt Prater Ari Robbie Gould SF
    140 drop-add Rashod Bateman Bal Nick Folk NE
    141 drop-add Sammy Watkins Bal Kenyan Drake LV
    142 drop-add Minnesota Min Indianapolis Ind
    143 drop-add Damien Williams Chi Justin Jackson LAC
    144 drop-add Samaje Perine Cin Chris Evans Cin
    145 drop-add Jamison Crowder NYJ Demetric Felton Cle
    146 drop-add Alex Collins Sea Bryan Edwards LV
    147 drop-add Hunter Henry NE Derek Carr LV
    148 drop-add Pittsburgh Pit Green Bay GB
    149 drop-add Khalil Herbert Chi Nick Westbrook-Ikhine Ten
    150 drop Bench N/A Cameron Brate TB
    151 trade Christian McCaffrey Car N/A N/A
    152 trade Stefon Diggs Buf N/A N/A
    153 trade Clyde Edwards-Helaire KC N/A N/A
    154 trade Dalton Schultz Dal N/A N/A
    155 trade Tim Patrick Den N/A N/A
    156 trade George Kittle SF N/A N/A
    157 trade Amari Cooper Dal N/A N/A
    158 drop-add Baltimore Bal Atlanta Atl
    159 add Ryan Succop TB Bench N/A
    160 drop-add Olamide Zaccheaus Atl Phillip Lindsay Mia
    161 drop-add Nick Folk NE Ryan Succop TB
    162 drop-add Derek Carr LV Sam Darnold Car
    163 drop-add Kenyan Drake LV Justin Fields Chi
    164 drop-add New Orleans NO Benny Snell Jr. Pit
    165 drop-add Zach Ertz Ari Le'Veon Bell TB
    166 drop-add Darrel Williams KC Marlon Mack Ind
    167 drop-add Sam Darnold Car Nyheim Hines Ind
    168 drop-add Joe Burrow Cin Rashod Bateman Bal
    169 drop-add Mo Alie-Cox Ind Curtis Samuel Was
    170 drop-add Marlon Mack Ind JuJu Smith-Schuster Pit
    171 drop Bench N/A New Orleans NO
    172 drop-add Ryan Succop TB Younghoe Koo Atl
    173 drop-add Miami Mia Washington Was
    174 drop-add Austin Seibert Det Greg Joseph Min
    175 drop-add Taylor Heinicke Was Kirk Cousins Min
    176 drop-add Bryan Edwards LV Ronald Jones II TB
    177 drop-add Cincinnati Cin Baltimore Bal
    178 drop-add Amon-Ra St. Brown Det Van Jefferson Jr. LAR
    179 drop-add Jarvis Landry Cle Tyler Conklin Min
    180 drop-add Indianapolis Ind Minnesota Min
    181 drop-add Nelson Agholor NE Josh Gordon KC
    182 drop-add Dan Arnold Jax Mo Alie-Cox Ind
    183 add Devontae Booker NYG Bench N/A
    184 drop-add Rashod Bateman Bal Marlon Mack Ind
    185 drop-add Mecole Hardman KC Quintez Cephus Det
    186 drop-add Jerick McKinnon KC Bryan Edwards LV
    187 drop-add Nyheim Hines Ind Daniel Jones NYG
    188 drop-add Rhamondre Stevenson NE Trey Lance SF
    189 drop-add Carolina Car Miami Mia
    190 drop-add Chris Evans Cin Olamide Zaccheaus Atl
    191 drop-add T.Y. Hilton Ind Mark Ingram II NO
    192 trade Josh Allen Buf N/A N/A
    193 trade Miles Sanders Phi N/A N/A
    194 trade Darrel Williams KC N/A N/A
    195 trade David Johnson Hou N/A N/A
    196 drop-add Green Bay GB Kansas City KC
    197 drop-add Marlon Mack Ind Jerick McKinnon KC
    198 drop-add Demetric Felton Cle Kenyan Drake LV
    199 drop-add J.K. Dobbins Bal Latavius Murray Bal
    200 drop-add Greg Joseph Min Austin Seibert Det
    201 drop-add Ricky Seals-Jones Was J.D. McKissic Was
    202 trade Mike Gesicki Mia N/A N/A
    203 trade Alex Collins Sea N/A N/A
    204 drop-add Jerick McKinnon KC Taylor Heinicke Was
    205 drop-add Mark Ingram II NO Larry Rountree III LAC
    206 drop-add D'Ernest Johnson Cle Mark Ingram II NO
    207 drop-add Matt Ryan Atl Sam Darnold Car
    208 drop-add Kirk Cousins Min Derek Carr LV
    209 drop-add Kenyan Drake LV David Johnson Hou
    210 drop-add Mason Crosby GB Greg Joseph Min
    211 drop-add Carson Wentz Ind Jerick McKinnon KC
    212 drop-add New Orleans NO Denver Den
    213 drop-add Baltimore Bal Dallas Dal
    214 drop-add Arizona Ari Cincinnati Cin
    215 drop-add Younghoe Koo Atl Chase McLaughlin Cle
    216 drop-add Evan Engram NYG Ty'Son Williams Bal
    217 drop-add Rashaad Penny Sea Peyton Barber LV
    218 drop-add J.D. McKissic Was Rondale Moore Ari
    219 drop-add Latavius Murray Bal Jamison Crowder NYJ
    220 drop-add Tua Tagovailoa Mia Kenneth Gainwell Phi
    221 drop-add Las Vegas LV Pittsburgh Pit
    222 drop-add Randy Bullock Ten Tyler Bass Buf
    223 drop-add Donovan Peoples-Jones Cle Kenyan Drake LV
    224 drop-add San Francisco SF Robert Tonyan GB
    225 drop-add Mark Ingram II NO Jameis Winston NO
    226 drop-add Deshaun Watson Hou Nick Folk NE
    227 drop-add Pat Freiermuth Pit Dan Arnold Jax
    228 drop-add Devonta Freeman Bal Pat Freiermuth Pit
    229 trade Rashod Bateman Bal N/A N/A
    230 trade Ricky Seals-Jones Was N/A N/A
    231 drop-add Kendrick Bourne NE Ty Johnson NYJ
    232 drop-add Graham Gano NYG Greg Zuerlein Dal
    233 drop-add DeeJay Dallas Sea Samaje Perine Cin
    234 drop-add Nick Folk NE Deshaun Watson Hou
    235 drop-add Tyler Bass Buf Devonta Freeman Bal
    236 drop-add Derek Carr LV Carson Wentz Ind
    237 drop-add Allen Lazard GB Graham Gano NYG
    238 drop-add Greg Zuerlein Dal Mecole Hardman KC
    239 drop-add JaMycal Hasty SF DeeJay Dallas Sea
    240 drop-add Rondale Moore Ari Sterling Shepard NYG
    241 drop-add Cole Kmet Chi Jonnu Smith NE
    242 drop-add Devonta Freeman Bal JaMycal Hasty SF
    243 drop-add Kenyan Drake LV Rhamondre Stevenson NE
    244 drop-add Jake Elliott Phi Chris Evans Cin
    245 drop-add Dallas Dal Kenyan Drake LV
    246 drop Bench N/A Matt Ryan Atl
    247 drop Bench N/A San Francisco SF
    248 drop-add Kenneth Gainwell Phi Will Fuller V Mia
    249 drop-add Pat Freiermuth Pit Ryan Succop TB
    250 drop-add Graham Gano NYG Mark Ingram II NO
    251 drop-add Samaje Perine Cin Derek Carr LV
    252 add Randall Cobb GB Bench N/A
    253 add Robert Tonyan GB Bench N/A
    254 drop-add Seattle Sea Indianapolis Ind
    255 drop-add Evan McPherson Cin Mason Crosby GB
    256 drop-add C.J. Uzomah Cin Cole Kmet Chi
    257 drop-add Russell Gage Atl Baltimore Bal
    258 drop-add Darius Slayton NYG Donovan Peoples-Jones Cle
    259 drop-add Kenyan Drake LV Damien Williams Chi
    260 drop-add Sterling Shepard NYG Ricky Seals-Jones Was
    261 drop-add Cincinnati Cin Trey Sermon SF
    262 drop-add Pittsburgh Pit New Orleans NO
    263 drop-add Marquez Valdes-Scantling GB Rondale Moore Ari
    264 drop-add Denver Den Carolina Car
    265 drop-add Tyler Conklin Min Allen Lazard GB
    266 drop-add Chase McLaughlin Cle Jake Elliott Phi
    267 drop-add David Johnson Hou Pat Freiermuth Pit
    268 drop-add Phillip Lindsay Mia Marquez Valdes-Scantling GB
    269 drop-add San Francisco SF Denver Den
    270 drop-add Justin Jackson LAC Marlon Mack Ind
    271 drop-add Chicago Chi Las Vegas LV
    272 drop-add Joshua Kelley LAC Nelson Agholor NE
    273 drop-add Indianapolis Ind New England NE
    274 drop-add Carolina Car Seattle Sea
    275 drop-add Mark Ingram II NO Phillip Lindsay Mia
    276 drop-add Ricky Seals-Jones Was C.J. Uzomah Cin
    277 drop-add Carson Wentz Ind Tua Tagovailoa Mia
    278 drop-add Jordan Howard Phi Joshua Kelley LAC
    279 drop-add Boston Scott Phi Justin Jackson LAC
    280 drop-add Daniel Jones NYG Carson Wentz Ind
    281 drop-add C.J. Uzomah Cin Zach Pascal Ind
    282 drop-add Jamal Agnew Jax Amon-Ra St. Brown Det
    283 drop-add Derek Carr LV David Johnson Hou
    284 drop-add Ty'Son Williams Bal Samaje Perine Cin
    285 drop-add Greg Joseph Min Randy Bullock Ten
    286 drop-add Van Jefferson Jr. LAR T.Y. Hilton Ind
    287 drop-add Miami Mia Carolina Car
    288 drop-add Carlos Hyde Jax Randall Cobb GB
    289 drop-add New Orleans NO Arizona Ari
    290 drop-add Foster Moreau LV Ricky Seals-Jones Was
    291 drop-add Jeff Wilson Jr. SF Daniel Jones NYG
    292 drop-add Bryan Edwards LV Rashaad Penny Sea
    293 drop-add Adrian Peterson Sea Devonta Freeman Bal
    294 drop-add Jeremy McNichols Ten Green Bay GB
    295 drop-add Jamison Crowder NYJ Kirk Cousins Min
    296 drop-add Carson Wentz Ind Graham Gano NYG
    297 drop-add Pat Freiermuth Pit Allen Robinson II Chi
    298 drop-add Rex Burkhead Hou Robert Tonyan GB
    299 drop-add Michael Badgley Ind Evan McPherson Cin
    300 drop-add Derrick Gore KC Darius Slayton NYG
    301 drop-add Elijah Moore NYJ Sterling Shepard NYG
    302 drop-add Dan Arnold Jax Demetric Felton Cle
    303 drop-add New England NE Brandon Aiyuk SF
    304 drop-add Peyton Barber LV Henry Ruggs III LV
    305 drop-add Los Angeles LAC San Francisco SF
    306 drop-add Brandon Bolden NE Tyler Conklin Min
    307 drop-add Allen Robinson II Chi Robby Anderson Car
    308 drop-add Donovan Peoples-Jones Cle Greg Zuerlein Dal
    309 drop-add San Francisco SF Los Angeles LAC
    310 drop-add Greg Zuerlein Dal Younghoe Koo Atl
    311 drop-add Rondale Moore Ari Rex Burkhead Hou
    312 drop-add Brandon Aiyuk SF DeVante Parker Mia
    313 drop-add Jimmy Garoppolo SF Sammy Watkins Bal
    314 drop-add James Washington Pit Logan Thomas Was
    315 drop-add Cole Kmet Chi Michael Thomas NO
    316 drop-add Tennessee Ten New Orleans NO
    317 drop-add Devonta Freeman Bal Peyton Barber LV
    318 drop-add Arizona Ari Ty'Son Williams Bal
    319 drop-add Baltimore Bal Cincinnati Cin
    320 drop-add Logan Thomas Was Greg Zuerlein Dal
    321 drop-add Malik Turner Dal K.J. Osborn Min
    322 drop-add T.Y. Hilton Ind Latavius Murray Bal
    323 drop-add Michael Thomas NO Foster Moreau LV
    324 drop-add DeSean Jackson LV Bryan Edwards LV
    325 drop-add Chris Boswell Pit Jeff Wilson Jr. SF
    326 drop-add Denver Den Chicago Chi
    327 drop-add Younghoe Koo Atl Brandon McManus Den
    328 drop-add Deonte Harris NO James Washington Pit
    329 drop-add Eno Benjamin Ari Cole Kmet Chi
    330 drop-add Rashaad Penny Sea Dallas Dal
    331 drop-add Philadelphia Phi San Francisco SF
    332 drop-add Rhamondre Stevenson NE Carlos Hyde Jax
    333 drop-add Travis Etienne Jax Boston Scott Phi
    334 drop-add Le'Veon Bell TB Dan Arnold Jax
    335 drop-add Los Angeles LAC Philadelphia Phi
    336 drop-add Cam Newton Car Malik Turner Dal
    337 drop Bench N/A Miami Mia
    338 add Philadelphia Phi Bench N/A
    339 drop-add Dallas Dal Philadelphia Phi
    340 drop-add Boston Scott Phi Van Jefferson Jr. LAR
    341 drop-add Carlos Hyde Jax Rashaad Penny Sea
    342 drop-add Josh Reynolds Det Zach Ertz Ari
    343 drop-add Kirk Cousins Min Le'Veon Bell TB
    344 drop-add Van Jefferson Jr. LAR Robert Woods LAR
    345 drop-add Jeff Wilson Jr. SF Chuba Hubbard Car
    346 drop-add Zach Pascal Ind New England NE
    347 drop-add Bryan Edwards LV Carlos Hyde Jax
    348 drop-add Sterling Shepard NYG Derrick Gore KC
    349 drop-add San Francisco SF Derek Carr LV
    350 trade T.Y. Hilton Ind N/A N/A
    351 drop-add Wayne Gallman Jr. Min Tim Patrick Den
    352 drop-add Ryan Succop TB Michael Badgley Ind
    353 drop-add Randy Bullock Ten Matt Gay LAR
    354 drop-add Marcus Johnson Ten Russell Gage Atl
    355 drop-add Dan Arnold Jax Dalton Schultz Dal
    356 drop-add Justin Fields Chi Pittsburgh Pit
    357 drop-add Miami Mia Arizona Ari
    358 drop-add Carolina Car Los Angeles LAC
    359 drop-add Zach Ertz Ari Kenny Golladay NYG
    360 drop-add New England NE Dallas Dal
    361 drop-add D'Onta Foreman Ten Adrian Peterson Sea
    362 drop-add Robert Woods LAR Michael Thomas NO
    363 trade Mike Davis Atl N/A N/A
    364 drop-add Philadelphia Phi Los Angeles LAR
    365 drop-add Carlos Hyde Jax Julio Jones Ten
    366 drop-add Latavius Murray Bal Jamal Agnew Jax
    367 drop-add Ty Johnson NYJ Noah Fant Den
    368 drop-add Will Fuller V Mia Ty Johnson NYJ
    369 drop-add Arizona Ari Indianapolis Ind
    370 drop-add Kenny Golladay NYG Sterling Shepard NYG
    371 drop-add Dalton Schultz Dal Zach Ertz Ari
    372 drop-add Jamal Agnew Jax Wayne Gallman Jr. Min
    373 drop-add Zane Gonzalez Car Ryan Succop TB
    374 drop-add Robby Anderson Car Will Fuller V Mia
    375 drop-add Kalif Raymond Det Allen Robinson II Chi
    376 drop-add Trey Sermon SF Sony Michel LAR
    377 drop-add Rashaad Penny Sea Robby Anderson Car
    378 drop-add Los Angeles LAC Denver Den
    379 drop-add Gary Brightwell NYG Rashaad Penny Sea
    380 drop-add Marquez Valdes-Scantling GB Kalif Raymond Det
    381 drop-add Cedrick Wilson Dal Carlos Hyde Jax
    382 drop-add Derek Carr LV Cam Newton Car
    383 drop-add Tua Tagovailoa Mia Kirk Cousins Min
    384 drop-add Rashaad Penny Sea Marcus Johnson Ten
    385 drop-add Ben Roethlisberger Pit Jimmy Garoppolo SF
    386 drop-add Dallas Dal Justin Fields Chi
    387 drop-add Sony Michel LAR Josh Reynolds Det
    388 drop-add Sterling Shepard NYG Bryan Edwards LV
    389 drop-add Ronald Jones II TB Kenyan Drake LV
    390 drop-add Noah Fant Den Rashaad Penny Sea
    391 drop-add Cam Akers LAR Logan Thomas Was
    392 drop Bench N/A Jamal Agnew Jax
    393 drop Bench N/A Devontae Booker NYG
    394 drop-add Pittsburgh Pit Derek Carr LV
    395 drop-add Houston Hou Tennessee Ten
    396 drop-add Logan Thomas Was Dan Arnold Jax
    397 drop-add Tre'Quan Smith NO Zack Moss Buf
    398 drop-add David Johnson Hou Gary Brightwell NYG
    399 drop-add Michael Thomas NO J.D. McKissic Was
    400 drop-add Greg Zuerlein Dal Zane Gonzalez Car
    401 drop-add Ty Johnson NYJ Kenny Golladay NYG
    402 drop-add Kirk Cousins Min Ronald Jones II TB
    403 drop-add Allen Robinson II Chi A.J. Green Ari
    404 drop-add Brandon McManus Den Tua Tagovailoa Mia
    405 drop-add Chicago Chi Harrison Butker KC
    406 drop-add Cam Newton Car Boston Scott Phi
    407 drop-add Matt Gay LAR Randy Bullock Ten
    408 add Robby Anderson Car Bench N/A
    409 add DeAndre Carter Was Bench N/A
    410 drop-add Ryan Succop TB Jeremy McNichols Ten
    411 drop-add Tony Jones Jr. NO Trey Sermon SF
    412 drop-add Matt Breida Buf Brandon Bolden NE
    413 drop-add Jake Elliott Phi Chase McLaughlin Cle
    414 drop-add Rex Burkhead Hou Mark Ingram II NO
    415 drop-add Nick Westbrook-Ikhine Ten DeAndre Carter Was
    416 drop-add DeeJay Dallas Sea Sterling Shepard NYG
    417 drop-add J.D. McKissic Was Sony Michel LAR
    418 drop-add Chuba Hubbard Car Christian McCaffrey Car
    419 drop-add Mark Ingram II NO Marquez Valdes-Scantling GB
    420 drop-add Harrison Butker KC Brandon McManus Den
    421 drop-add Dontrell Hilliard Ten Rex Burkhead Hou
    422 drop-add Evan McPherson Cin Chris Boswell Pit
    423 drop-add Indianapolis Ind Houston Hou
    424 drop-add Minnesota Min Robby Anderson Car
    425 drop-add Kansas City KC Carolina Car
    426 drop-add Los Angeles LAR Chicago Chi
    427 drop-add Foster Moreau LV Pittsburgh Pit
    428 drop-add Russell Gage Atl Noah Fant Den
    429 drop-add Jack Doyle Ind C.J. Uzomah Cin
    430 drop-add JuJu Smith-Schuster Pit Tre'Quan Smith NO
    431 drop-add Sony Michel LAR Dallas Dal
    432 drop-add Zach Ertz Ari Dontrell Hilliard Ten
    433 drop-add Taysom Hill NO Ryan Tannehill Ten
    434 drop-add Sterling Shepard NYG Tony Jones Jr. NO
    435 drop-add DeVante Parker Mia Latavius Murray Bal
    436 drop-add Curtis Samuel Was Mike Davis Atl
    437 drop-add Boston Scott Phi Donovan Peoples-Jones Cle
    438 drop-add Kenny Golladay NYG Cedrick Wilson Dal
    439 drop-add Cincinnati Cin Cleveland Cle
    440 drop-add Christian McCaffrey Car Eno Benjamin Ari
    441 drop-add Dontrell Hilliard Ten Mike Gesicki Mia
    442 drop-add Marlon Mack Ind Cam Newton Car
    443 drop-add A.J. Green Ari J.D. McKissic Was
    444 drop-add Tevin Coleman NYJ Khalil Herbert Chi
    445 drop-add Derek Carr LV D'Ernest Johnson Cle
    446 drop-add Zack Moss Buf Jeff Wilson Jr. SF
    447 drop-add Julio Jones Ten Rondale Moore Ari
    448 drop Bench N/A Deonte Harris NO
    449 drop Bench N/A Marquez Callaway NO
    450 drop-add Marquez Valdes-Scantling GB Kenny Golladay NYG
    451 drop-add Dallas Dal Rashod Bateman Bal
    452 drop-add New Orleans NO Minnesota Min
    453 drop-add JaMycal Hasty SF Zack Moss Buf
    454 drop-add K.J. Osborn Min Logan Thomas Was
    455 drop-add Rashaad Penny Sea A.J. Green Ari
    456 drop-add Khalil Herbert Chi Ty Johnson NYJ
    457 drop-add Green Bay GB Miami Mia
    458 drop-add Tennessee Ten Indianapolis Ind
    459 drop-add Denver Den Los Angeles LAR
    460 drop-add Dustin Hopkins LAC Corey Davis NYJ
    461 add Noah Fant Den Bench N/A
    462 add Tre'Quan Smith NO Bench N/A
    463 drop-add Carolina Car Philadelphia Phi
    464 drop-add Seattle Sea Tennessee Ten
    465 drop-add Jeff Wilson Jr. SF Curtis Samuel Was
    466 drop-add Mason Crosby GB Greg Joseph Min
    467 drop-add Teddy Bridgewater Den Jack Doyle Ind
    468 drop-add Chris Boswell Pit Jake Elliott Phi
    469 drop-add Cleveland Cle Cincinnati Cin
    470 drop-add Tennessee Ten Zach Pascal Ind
    471 drop-add Rashod Bateman Bal DeeJay Dallas Sea
    472 drop-add Philadelphia Phi New Orleans NO
    473 drop-add Miami Mia Foster Moreau LV
    474 drop-add A.J. Green Ari T.Y. Hilton Ind
    475 drop-add Jermar Jefferson Det Mark Ingram II NO
    476 drop-add Gerald Everett Sea Robert Woods LAR
    477 drop-add Indianapolis Ind Dustin Hopkins LAC
    478 drop-add Tua Tagovailoa Mia DeSean Jackson LV
    479 drop-add Los Angeles LAR Denver Den
    480 drop-add Jason Sanders Mia Mason Crosby GB
    481 drop-add Robert Woods LAR Tevin Coleman NYJ
    482 drop-add Mike Gesicki Mia Jermar Jefferson Det
    483 drop-add Gabriel Davis Buf JaMycal Hasty SF
    484 drop-add Malcolm Brown Mia Dontrell Hilliard Ten
    485 drop-add D'Ernest Johnson Cle Nick Westbrook-Ikhine Ten
    486 drop-add Jimmy Garoppolo SF Tua Tagovailoa Mia
    487 drop-add Rondale Moore Ari DeAndre Hopkins Ari
    488 drop-add Allen Lazard GB Jeff Wilson Jr. SF
    489 drop-add Amon-Ra St. Brown Det T.J. Hockenson Det
    490 drop-add Mike Davis Atl Derek Carr LV
    491 drop-add Ronald Jones II TB Kirk Cousins Min
    492 drop-add DeAndre Hopkins Ari Sterling Shepard NYG
    493 drop-add Denver Den Carolina Car
    494 drop-add Jeff Wilson Jr. SF Malcolm Brown Mia
    495 drop-add Donovan Peoples-Jones Cle Allen Robinson II Chi
    496 drop-add Ben Skowronek LAR Allen Lazard GB
    497 drop-add T.J. Hockenson Det Ronald Jones II TB
    498 drop-add Allen Lazard GB Ben Skowronek LAR
    499 drop-add Ricky Seals-Jones Was T.J. Hockenson Det
    500 drop-add David Njoku Cle Emmanuel Sanders Buf
    501 drop-add J.D. McKissic Was Rondale Moore Ari
    502 drop-add Jaret Patterson Was J.D. McKissic Was
    503 drop-add Ronald Jones II TB Ricky Seals-Jones Was
    504 drop-add Justin Jackson LAC D'Ernest Johnson Cle
    505 drop-add Craig Reynolds Det Indianapolis Ind
    506 drop-add T.J. Hockenson Det K.J. Osborn Min
    507 drop-add New York NYJ Los Angeles LAR
    508 drop-add Scotty Miller TB Jerry Jeudy Den
    509 drop-add Mecole Hardman KC Allen Lazard GB
    510 drop-add Michael Badgley Ind Harrison Butker KC
    511 drop-add Mac Jones NE Arizona Ari
    512 drop-add DJ Chark Jr. Jax Jimmy Garoppolo SF
    513 drop-add Josh Reynolds Det Scotty Miller TB
    514 drop-add Tim Patrick Den David Johnson Hou
    515 drop-add Rondale Moore Ari Josh Reynolds Det
    516 drop-add Tyler Johnson TB Julio Jones Ten
    517 drop-add Kenny Golladay NYG Matt Breida Buf
    518 drop-add Ameer Abdullah Car Mike Davis Atl
    519 drop-add Emmanuel Sanders Buf Gabriel Davis Buf
    520 drop-add Marquez Callaway NO Jamison Crowder NYJ
    521 drop-add Cole Kmet Chi Pat Freiermuth Pit
    522 drop-add Allen Lazard GB Donovan Peoples-Jones Cle
    523 drop-add New Orleans NO Cleveland Cle
    524 drop-add Byron Pringle KC Russell Wilson Sea
    525 drop-add Scotty Miller TB Byron Pringle KC
    526 drop-add Laquon Treadwell Jax Scotty Miller TB
    527 drop-add Cincinnati Cin New York NYJ
    528 drop-add Joshua Kelley LAC Mecole Hardman KC
    529 drop-add Joshua Palmer LAC Laquon Treadwell Jax
    530 drop-add Matt Ryan Atl Taysom Hill NO
    531 drop-add Zack Moss Buf Rondale Moore Ari
    532 drop-add Pat Freiermuth Pit Darrell Henderson Jr. LAR
    533 drop-add Indianapolis Ind Myles Gaskin Mia
    534 drop-add Chicago Chi Kansas City KC
    535 drop-add Ke'Shawn Vaughn TB Jason Sanders Mia
    536 drop-add Derrick Gore KC Green Bay GB
    537 drop-add Russell Wilson Sea Tennessee Ten
    538 drop-add Trey Lance SF Chuba Hubbard Car
    539 drop-add K.J. Osborn Min Craig Reynolds Det
    540 drop-add Foster Moreau LV Cole Kmet Chi
    541 drop-add Darrell Henderson Jr. LAR Teddy Bridgewater Den
    542 drop-add Raheem Mostert SF Joshua Kelley LAC
    543 drop-add Green Bay GB Indianapolis Ind
    544 drop-add Josh Gordon KC Joshua Palmer LAC
    545 drop-add Gabriel Davis Buf Tyler Johnson TB
    546 drop-add Trey Sermon SF Philadelphia Phi
    547 drop-add Deonte Harris NO Emmanuel Sanders Buf
    548 drop-add D'Ernest Johnson Cle San Francisco SF
    


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
      <td>Darrell Henderson Jr.</td>
      <td>RB</td>
      <td>LAR</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>1</th>
      <td>132</td>
      <td>David Njoku</td>
      <td>TE</td>
      <td>Cle</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>2</th>
      <td>145</td>
      <td>Matt Gay</td>
      <td>K</td>
      <td>LAR</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>3</th>
      <td>157</td>
      <td>Marlon Mack</td>
      <td>RB</td>
      <td>Ind</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>4</th>
      <td>129</td>
      <td>Christian Kirk</td>
      <td>WR</td>
      <td>Ari</td>
      <td>8</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>5</th>
      <td>126</td>
      <td>DeVonta Smith</td>
      <td>WR</td>
      <td>Phi</td>
      <td>12</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>6</th>
      <td>71</td>
      <td>Melvin Gordon III</td>
      <td>RB</td>
      <td>Den</td>
      <td>21</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>7</th>
      <td>10</td>
      <td>CeeDee Lamb</td>
      <td>WR</td>
      <td>DAL</td>
      <td>23</td>
      <td>Chi Shing</td>
      <td>E</td>
    </tr>
    <tr>
      <th>8</th>
      <td>11</td>
      <td>Patrick Mahomes</td>
      <td>QB</td>
      <td>KC</td>
      <td>24</td>
      <td>Chi Shing</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>9</th>
      <td>91</td>
      <td>Tyler Higbee</td>
      <td>TE</td>
      <td>LAR</td>
      <td>25</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>10</th>
      <td>82</td>
      <td>Kareem Hunt</td>
      <td>RB</td>
      <td>Cle</td>
      <td>32</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>11</th>
      <td>65</td>
      <td>Chris Godwin</td>
      <td>WR</td>
      <td>TB</td>
      <td>57</td>
      <td>Chi Shing</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>12</th>
      <td>9</td>
      <td>Joe Mixon</td>
      <td>RB</td>
      <td>CIN</td>
      <td>72</td>
      <td>Chi Shing</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>13</th>
      <td>136</td>
      <td>Robert Woods</td>
      <td>WR</td>
      <td>LAR</td>
      <td>12</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>14</th>
      <td>86</td>
      <td>Evan Engram</td>
      <td>TE</td>
      <td>NYG</td>
      <td>2</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>15</th>
      <td>46</td>
      <td>D'Onta Foreman</td>
      <td>RB</td>
      <td>Ten</td>
      <td>9</td>
      <td>Chi Shing</td>
      <td></td>
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
      <td>DeVante Parker</td>
      <td>WR</td>
      <td>Mia</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>17</th>
      <td>119</td>
      <td>Khalil Herbert</td>
      <td>RB</td>
      <td>Chi</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>18</th>
      <td>127</td>
      <td>Ke'Shawn Vaughn</td>
      <td>RB</td>
      <td>TB</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>19</th>
      <td>138</td>
      <td>Kadarius Toney</td>
      <td>WR</td>
      <td>NYG</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>20</th>
      <td>139</td>
      <td>Rashaad Penny</td>
      <td>RB</td>
      <td>Sea</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>21</th>
      <td>169</td>
      <td>Rashod Bateman</td>
      <td>WR</td>
      <td>Bal</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>22</th>
      <td>170</td>
      <td>Derrick Gore</td>
      <td>RB</td>
      <td>KC</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>23</th>
      <td>182</td>
      <td>JuJu Smith-Schuster</td>
      <td>WR</td>
      <td>Pit</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>24</th>
      <td>162</td>
      <td>Michael Carter</td>
      <td>RB</td>
      <td>NYJ</td>
      <td>3</td>
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
      <td>2</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>31</th>
      <td>122</td>
      <td>DeAndre Hopkins</td>
      <td>WR</td>
      <td>Ari</td>
      <td>34</td>
      <td>Dai</td>
      <td></td>
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
      <td>57</td>
      <td>Jaret Patterson</td>
      <td>RB</td>
      <td>Was</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>33</th>
      <td>97</td>
      <td>Allen Lazard</td>
      <td>WR</td>
      <td>GB</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>34</th>
      <td>147</td>
      <td>Jeff Wilson Jr.</td>
      <td>RB</td>
      <td>SF</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>35</th>
      <td>148</td>
      <td>Buffalo</td>
      <td>DEF</td>
      <td>Buf</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>36</th>
      <td>185</td>
      <td>Deonte Harris</td>
      <td>WR</td>
      <td>NO</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>37</th>
      <td>0</td>
      <td>Rhamondre Stevenson</td>
      <td>RB</td>
      <td>NE</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>38</th>
      <td>0</td>
      <td>Gabriel Davis</td>
      <td>WR</td>
      <td>Buf</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>39</th>
      <td>0</td>
      <td>Trey Sermon</td>
      <td>RB</td>
      <td>SF</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>40</th>
      <td>168</td>
      <td>Jakobi Meyers</td>
      <td>WR</td>
      <td>NE</td>
      <td>1</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>41</th>
      <td>27</td>
      <td>Justin Herbert</td>
      <td>QB</td>
      <td>SD</td>
      <td>5</td>
      <td>Doug</td>
      <td>E</td>
    </tr>
    <tr>
      <th>42</th>
      <td>29</td>
      <td>James Robinson</td>
      <td>RB</td>
      <td>JAX</td>
      <td>5</td>
      <td>Doug</td>
      <td>E</td>
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
      <td>49</td>
      <td>Ezekiel Elliott</td>
      <td>RB</td>
      <td>Dal</td>
      <td>87</td>
      <td>Doug</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>45</th>
      <td>159</td>
      <td>Greg Zuerlein</td>
      <td>K</td>
      <td>Dal</td>
      <td>3</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>46</th>
      <td>0</td>
      <td>Justin Jackson</td>
      <td>RB</td>
      <td>LAC</td>
      <td>3</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>47</th>
      <td>67</td>
      <td>Marquez Valdes-Scantling</td>
      <td>WR</td>
      <td>GB</td>
      <td>4</td>
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
      <td></td>
    </tr>
    <tr>
      <th>49</th>
      <td>121</td>
      <td>Ben Roethlisberger</td>
      <td>QB</td>
      <td>Pit</td>
      <td>0</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>50</th>
      <td>133</td>
      <td>Jared Cook</td>
      <td>TE</td>
      <td>LAC</td>
      <td>0</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>51</th>
      <td>140</td>
      <td>Ryan Succop</td>
      <td>K</td>
      <td>TB</td>
      <td>0</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>52</th>
      <td>163</td>
      <td>Denver</td>
      <td>DEF</td>
      <td>Den</td>
      <td>0</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>53</th>
      <td>152</td>
      <td>Matt Prater</td>
      <td>K</td>
      <td>Ari</td>
      <td>2</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>54</th>
      <td>153</td>
      <td>Darnell Mooney</td>
      <td>WR</td>
      <td>Chi</td>
      <td>4</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>55</th>
      <td>116</td>
      <td>Michael Gallup</td>
      <td>WR</td>
      <td>Dal</td>
      <td>11</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>56</th>
      <td>128</td>
      <td>Jarvis Landry</td>
      <td>WR</td>
      <td>Cle</td>
      <td>15</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>57</th>
      <td>85</td>
      <td>Tyler Boyd</td>
      <td>WR</td>
      <td>Cin</td>
      <td>18</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>58</th>
      <td>77</td>
      <td>Damien Harris</td>
      <td>RB</td>
      <td>NE</td>
      <td>23</td>
      <td>Evan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>59</th>
      <td>41</td>
      <td>Kyler Murray</td>
      <td>QB</td>
      <td>ARI</td>
      <td>24</td>
      <td>Evan</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>60</th>
      <td>39</td>
      <td>Antonio Gibson</td>
      <td>RB</td>
      <td>WAS</td>
      <td>27</td>
      <td>Evan</td>
      <td>E</td>
    </tr>
    <tr>
      <th>61</th>
      <td>42</td>
      <td>Tyler Lockett</td>
      <td>WR</td>
      <td>SEA</td>
      <td>32</td>
      <td>Evan</td>
      <td>BCDE</td>
    </tr>
    <tr>
      <th>62</th>
      <td>6</td>
      <td>Miles Sanders</td>
      <td>RB</td>
      <td>Phi</td>
      <td>41</td>
      <td>Evan</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>63</th>
      <td>89</td>
      <td>Baltimore</td>
      <td>DEF</td>
      <td>Bal</td>
      <td>3</td>
      <td>Evan</td>
      <td></td>
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
      <td>Gerald Everett</td>
      <td>TE</td>
      <td>Sea</td>
      <td>0</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>65</th>
      <td>83</td>
      <td>DJ Chark Jr.</td>
      <td>WR</td>
      <td>Jax</td>
      <td>0</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>66</th>
      <td>84</td>
      <td>Miami</td>
      <td>DEF</td>
      <td>Mia</td>
      <td>0</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>67</th>
      <td>101</td>
      <td>Marquez Callaway</td>
      <td>WR</td>
      <td>NO</td>
      <td>0</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>68</th>
      <td>146</td>
      <td>Boston Scott</td>
      <td>RB</td>
      <td>Phi</td>
      <td>0</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>69</th>
      <td>151</td>
      <td>Mac Jones</td>
      <td>QB</td>
      <td>NE</td>
      <td>0</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>70</th>
      <td>156</td>
      <td>A.J. Green</td>
      <td>WR</td>
      <td>Ari</td>
      <td>0</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>71</th>
      <td>106</td>
      <td>Justin Tucker</td>
      <td>K</td>
      <td>Bal</td>
      <td>2</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>72</th>
      <td>112</td>
      <td>Cole Beasley</td>
      <td>WR</td>
      <td>Buf</td>
      <td>2</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>73</th>
      <td>74</td>
      <td>James Conner</td>
      <td>RB</td>
      <td>Ari</td>
      <td>16</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>74</th>
      <td>24</td>
      <td>Cooper Kupp</td>
      <td>WR</td>
      <td>LAR</td>
      <td>26</td>
      <td>Jake</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>75</th>
      <td>76</td>
      <td>Josh Jacobs</td>
      <td>RB</td>
      <td>LV</td>
      <td>38</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>76</th>
      <td>64</td>
      <td>Lamar Jackson</td>
      <td>QB</td>
      <td>Bal</td>
      <td>47</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>77</th>
      <td>62</td>
      <td>Mike Evans</td>
      <td>WR</td>
      <td>TB</td>
      <td>48</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>78</th>
      <td>23</td>
      <td>Darren Waller</td>
      <td>TE</td>
      <td>LV</td>
      <td>56</td>
      <td>Jake</td>
      <td>E</td>
    </tr>
    <tr>
      <th>79</th>
      <td>26</td>
      <td>Devonta Freeman</td>
      <td>RB</td>
      <td>Bal</td>
      <td>6</td>
      <td>Jake</td>
      <td></td>
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
      <td></td>
    </tr>
    <tr>
      <th>81</th>
      <td>100</td>
      <td>Chris Boswell</td>
      <td>K</td>
      <td>Pit</td>
      <td>0</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>82</th>
      <td>131</td>
      <td>Kendrick Bourne</td>
      <td>WR</td>
      <td>NE</td>
      <td>0</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>83</th>
      <td>137</td>
      <td>New Orleans</td>
      <td>DEF</td>
      <td>NO</td>
      <td>0</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>84</th>
      <td>149</td>
      <td>Kenny Golladay</td>
      <td>WR</td>
      <td>NYG</td>
      <td>0</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>85</th>
      <td>160</td>
      <td>Ameer Abdullah</td>
      <td>RB</td>
      <td>Car</td>
      <td>0</td>
      <td>Jiwei</td>
      <td></td>
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
      <td></td>
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
      <td>32</td>
      <td>Pat Freiermuth</td>
      <td>TE</td>
      <td>Pit</td>
      <td>0</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>97</th>
      <td>33</td>
      <td>Amon-Ra St. Brown</td>
      <td>WR</td>
      <td>Det</td>
      <td>0</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>98</th>
      <td>51</td>
      <td>D'Ernest Johnson</td>
      <td>RB</td>
      <td>Cle</td>
      <td>0</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>99</th>
      <td>61</td>
      <td>Foster Moreau</td>
      <td>TE</td>
      <td>LV</td>
      <td>0</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>100</th>
      <td>165</td>
      <td>Leonard Fournette</td>
      <td>RB</td>
      <td>TB</td>
      <td>0</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>101</th>
      <td>177</td>
      <td>Tyler Bass</td>
      <td>K</td>
      <td>Buf</td>
      <td>0</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>102</th>
      <td>93</td>
      <td>Brandin Cooks</td>
      <td>WR</td>
      <td>Hou</td>
      <td>11</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>103</th>
      <td>104</td>
      <td>Deebo Samuel</td>
      <td>WR</td>
      <td>SF</td>
      <td>13</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>104</th>
      <td>34</td>
      <td>Aaron Rodgers</td>
      <td>QB</td>
      <td>GB</td>
      <td>15</td>
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
      <td>0</td>
      <td>Ronald Jones II</td>
      <td>RB</td>
      <td>TB</td>
      <td>14</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>110</th>
      <td>79</td>
      <td>Dallas</td>
      <td>DEF</td>
      <td>Dal</td>
      <td>4</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>111</th>
      <td>130</td>
      <td>Sony Michel</td>
      <td>RB</td>
      <td>LAR</td>
      <td>8</td>
      <td>Joel</td>
      <td></td>
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
      <td>4</td>
      <td>Zack Moss</td>
      <td>RB</td>
      <td>Buf</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>113</th>
      <td>12</td>
      <td>Mike Gesicki</td>
      <td>TE</td>
      <td>Mia</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>114</th>
      <td>80</td>
      <td>Raheem Mostert</td>
      <td>RB</td>
      <td>SF</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>115</th>
      <td>99</td>
      <td>Tim Patrick</td>
      <td>WR</td>
      <td>Den</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>116</th>
      <td>102</td>
      <td>Dalton Schultz</td>
      <td>TE</td>
      <td>Dal</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>117</th>
      <td>108</td>
      <td>Cincinnati</td>
      <td>DEF</td>
      <td>Cin</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>118</th>
      <td>109</td>
      <td>Travis Etienne</td>
      <td>RB</td>
      <td>Jax</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>119</th>
      <td>120</td>
      <td>Jordan Howard</td>
      <td>RB</td>
      <td>Phi</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>120</th>
      <td>150</td>
      <td>Michael Badgley</td>
      <td>K</td>
      <td>Ind</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>121</th>
      <td>190</td>
      <td>Brandon Aiyuk</td>
      <td>WR</td>
      <td>SF</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>122</th>
      <td>3</td>
      <td>Odell Beckham Jr.</td>
      <td>WR</td>
      <td>CLE</td>
      <td>5</td>
      <td>Matt</td>
      <td>E</td>
    </tr>
    <tr>
      <th>123</th>
      <td>107</td>
      <td>Matthew Stafford</td>
      <td>QB</td>
      <td>LAR</td>
      <td>10</td>
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
      <td>0</td>
      <td>New England</td>
      <td>DEF</td>
      <td>NE</td>
      <td>5</td>
      <td>Matt</td>
      <td></td>
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
      <td>95</td>
      <td>Matt Ryan</td>
      <td>QB</td>
      <td>Atl</td>
      <td>0</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>129</th>
      <td>113</td>
      <td>Los Angeles</td>
      <td>DEF</td>
      <td>LAC</td>
      <td>0</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>130</th>
      <td>143</td>
      <td>Nyheim Hines</td>
      <td>RB</td>
      <td>Ind</td>
      <td>0</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>131</th>
      <td>166</td>
      <td>Younghoe Koo</td>
      <td>K</td>
      <td>Atl</td>
      <td>0</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>132</th>
      <td>187</td>
      <td>Hunter Henry</td>
      <td>TE</td>
      <td>NE</td>
      <td>0</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>133</th>
      <td>0</td>
      <td>Noah Fant</td>
      <td>TE</td>
      <td>Den</td>
      <td>0</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>134</th>
      <td>0</td>
      <td>Tre'Quan Smith</td>
      <td>WR</td>
      <td>NO</td>
      <td>0</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>135</th>
      <td>179</td>
      <td>Devin Singletary</td>
      <td>RB</td>
      <td>Buf</td>
      <td>1</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>136</th>
      <td>171</td>
      <td>Marquise Brown</td>
      <td>WR</td>
      <td>Bal</td>
      <td>2</td>
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
      <td></td>
    </tr>
    <tr>
      <th>138</th>
      <td>22</td>
      <td>Terry McLaurin</td>
      <td>WR</td>
      <td>WAS</td>
      <td>49</td>
      <td>Rajiv</td>
      <td>E</td>
    </tr>
    <tr>
      <th>139</th>
      <td>69</td>
      <td>Adam Thielen</td>
      <td>WR</td>
      <td>Min</td>
      <td>49</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>140</th>
      <td>21</td>
      <td>Derrick Henry</td>
      <td>RB</td>
      <td>TEN</td>
      <td>56</td>
      <td>Rajiv</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>141</th>
      <td>48</td>
      <td>Saquon Barkley</td>
      <td>RB</td>
      <td>NYG</td>
      <td>79</td>
      <td>Rajiv</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>142</th>
      <td>105</td>
      <td>Kenneth Gainwell</td>
      <td>RB</td>
      <td>Phi</td>
      <td>23</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>143</th>
      <td>70</td>
      <td>Christian McCaffrey</td>
      <td>RB</td>
      <td>Car</td>
      <td>65</td>
      <td>Rajiv</td>
      <td></td>
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
      <td>20</td>
      <td>Green Bay</td>
      <td>DEF</td>
      <td>GB</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>145</th>
      <td>53</td>
      <td>Trey Lance</td>
      <td>QB</td>
      <td>SF</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>146</th>
      <td>60</td>
      <td>Josh Gordon</td>
      <td>WR</td>
      <td>KC</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>147</th>
      <td>110</td>
      <td>K.J. Osborn</td>
      <td>WR</td>
      <td>Min</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>148</th>
      <td>123</td>
      <td>Joe Burrow</td>
      <td>QB</td>
      <td>Cin</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>149</th>
      <td>135</td>
      <td>Cordarrelle Patterson</td>
      <td>WR,RB</td>
      <td>Atl</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>150</th>
      <td>158</td>
      <td>Chicago</td>
      <td>DEF</td>
      <td>Chi</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>151</th>
      <td>172</td>
      <td>Dawson Knox</td>
      <td>TE</td>
      <td>Buf</td>
      <td>4</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>152</th>
      <td>17</td>
      <td>DK Metcalf</td>
      <td>WR</td>
      <td>SEA</td>
      <td>12</td>
      <td>Ron</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>153</th>
      <td>111</td>
      <td>Dallas Goedert</td>
      <td>TE</td>
      <td>Phi</td>
      <td>13</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>154</th>
      <td>50</td>
      <td>Chase Edmonds</td>
      <td>RB</td>
      <td>Ari</td>
      <td>19</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>155</th>
      <td>63</td>
      <td>Ja'Marr Chase</td>
      <td>WR</td>
      <td>Cin</td>
      <td>19</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>156</th>
      <td>18</td>
      <td>Austin Ekeler</td>
      <td>RB</td>
      <td>SD</td>
      <td>22</td>
      <td>Ron</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>157</th>
      <td>103</td>
      <td>Courtland Sutton</td>
      <td>WR</td>
      <td>Den</td>
      <td>23</td>
      <td>Ron</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>158</th>
      <td>115</td>
      <td>Eli Mitchell</td>
      <td>RB</td>
      <td>SF</td>
      <td>43</td>
      <td>Ron</td>
      <td></td>
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
      <td>114</td>
      <td>Daniel Carlson</td>
      <td>K</td>
      <td>LV</td>
      <td>0</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>161</th>
      <td>173</td>
      <td>J.K. Dobbins</td>
      <td>RB</td>
      <td>Bal</td>
      <td>0</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>162</th>
      <td>175</td>
      <td>Rob Gronkowski</td>
      <td>TE</td>
      <td>TB</td>
      <td>1</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>163</th>
      <td>174</td>
      <td>Tony Pollard</td>
      <td>RB</td>
      <td>Dal</td>
      <td>2</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>164</th>
      <td>176</td>
      <td>Jamaal Williams</td>
      <td>RB</td>
      <td>Det</td>
      <td>2</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>165</th>
      <td>124</td>
      <td>Tampa Bay</td>
      <td>DEF</td>
      <td>TB</td>
      <td>4</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>166</th>
      <td>37</td>
      <td>Chase Claypool</td>
      <td>WR</td>
      <td>PIT</td>
      <td>5</td>
      <td>Ryan</td>
      <td>E</td>
    </tr>
    <tr>
      <th>167</th>
      <td>118</td>
      <td>Laviska Shenault Jr.</td>
      <td>WR</td>
      <td>Jax</td>
      <td>10</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>168</th>
      <td>88</td>
      <td>Tom Brady</td>
      <td>QB</td>
      <td>TB</td>
      <td>13</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>169</th>
      <td>36</td>
      <td>Nick Chubb</td>
      <td>RB</td>
      <td>CLE</td>
      <td>24</td>
      <td>Ryan</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>170</th>
      <td>181</td>
      <td>Michael Pittman Jr.</td>
      <td>WR</td>
      <td>Ind</td>
      <td>26</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>171</th>
      <td>35</td>
      <td>Travis Kelce</td>
      <td>TE</td>
      <td>KC</td>
      <td>73</td>
      <td>Ryan</td>
      <td>CDE</td>
    </tr>
    <tr>
      <th>172</th>
      <td>52</td>
      <td>Dalvin Cook</td>
      <td>RB</td>
      <td>Min</td>
      <td>111</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>173</th>
      <td>55</td>
      <td>Van Jefferson Jr.</td>
      <td>WR</td>
      <td>LAR</td>
      <td>11</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>174</th>
      <td>161</td>
      <td>Carson Wentz</td>
      <td>QB</td>
      <td>Ind</td>
      <td>11</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>175</th>
      <td>38</td>
      <td>Russell Wilson</td>
      <td>QB</td>
      <td>Sea</td>
      <td>2</td>
      <td>Ryan</td>
      <td></td>
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
      <td>142</td>
      <td>Seattle</td>
      <td>DEF</td>
      <td>Sea</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>177</th>
      <td>164</td>
      <td>Elijah Moore</td>
      <td>WR</td>
      <td>NYJ</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>178</th>
      <td>167</td>
      <td>Zach Ertz</td>
      <td>TE</td>
      <td>Ari</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>179</th>
      <td>178</td>
      <td>Evan McPherson</td>
      <td>K</td>
      <td>Cin</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>180</th>
      <td>188</td>
      <td>T.J. Hockenson</td>
      <td>TE</td>
      <td>Det</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>181</th>
      <td>189</td>
      <td>Cam Akers</td>
      <td>RB</td>
      <td>LAR</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>182</th>
      <td>16</td>
      <td>Dak Prescott</td>
      <td>QB</td>
      <td>DAL</td>
      <td>5</td>
      <td>Sean</td>
      <td>E</td>
    </tr>
    <tr>
      <th>183</th>
      <td>154</td>
      <td>Jaylen Waddle</td>
      <td>WR</td>
      <td>Mia</td>
      <td>5</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>184</th>
      <td>90</td>
      <td>Mike Williams</td>
      <td>WR</td>
      <td>LAC</td>
      <td>13</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>185</th>
      <td>14</td>
      <td>AJ Brown</td>
      <td>WR</td>
      <td>TEN</td>
      <td>18</td>
      <td>Sean</td>
      <td>DE</td>
    </tr>
    <tr>
      <th>186</th>
      <td>94</td>
      <td>Javonte Williams</td>
      <td>RB</td>
      <td>Den</td>
      <td>25</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>187</th>
      <td>13</td>
      <td>Alvin Kamara</td>
      <td>RB</td>
      <td>NO</td>
      <td>36</td>
      <td>Sean</td>
      <td>BCDE</td>
    </tr>
    <tr>
      <th>188</th>
      <td>54</td>
      <td>Amari Cooper</td>
      <td>WR</td>
      <td>Dal</td>
      <td>41</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>189</th>
      <td>19</td>
      <td>Stefon Diggs</td>
      <td>WR</td>
      <td>Buf</td>
      <td>46</td>
      <td>Sean</td>
      <td>E</td>
    </tr>
    <tr>
      <th>190</th>
      <td>58</td>
      <td>Clyde Edwards-Helaire</td>
      <td>RB</td>
      <td>KC</td>
      <td>68</td>
      <td>Sean</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>191</th>
      <td>183</td>
      <td>Michael Thomas</td>
      <td>WR</td>
      <td>NO</td>
      <td>2</td>
      <td>Sean</td>
      <td></td>
    </tr>
  </tbody>
</table>
</div>


