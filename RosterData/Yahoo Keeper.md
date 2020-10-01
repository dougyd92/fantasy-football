

```python
import pandas as pd
from splinter import Browser
from selenium import webdriver
from bs4 import BeautifulSoup
import requests
import numpy as np
import time
import json
from time import sleep
import sys
from datetime import datetime

pd.options.display.max_rows = 999

```


```python
# draft_results = pd.read_csv('G:\\Mydocs\\Fantasy Football 2020\\Draft2020.csv')
# draft_results.head()
```


```python
# draft_list = []
# for idr, rdr in draft_results.iterrows():
#     pick = rdr['Pick']
#     player_name = rdr['Player'].split(' (')[0].strip()
#     player_team = (rdr['Player'].split(' (')[1]).split(' - ')[0].strip()
#     player_pos = (rdr['Player'].split(' (')[1]).split(' - ')[1].replace(')', '').replace('?', '').strip()
#     salary = rdr['Salary']
#     ff_team = rdr['Team']
#     draft_dict = {
#         "pick": pick,
#         "player_name": player_name,
#         "player_team": player_team,
#         "player_position": player_pos,
#         "salary": salary,
#         "fantasy_football_team": ff_team
#     }
#     draft_list.append(draft_dict)
# draft_df = pd.DataFrame(draft_list)
# draft_df.head()
```


```python
# keepers = draft_df[147:]
# keeper_list = []
# for ik, rk in keepers.iterrows():
#     keeper_id = input("What is the keeper code for " + rk['player_name'] + " ? ")
#     keeper_dict = {
#         "player_name": rk['player_name'],
#         "keeper_code": keeper_id
#     }
#     keeper_list.append(keeper_dict)
# keeper_df = pd.DataFrame(keeper_list)
# keeper_df.head()
```


```python
# manager_list = []
# for m in list(set(draft_df['fantasy_football_team'])):
#     manager = input("Who is the Manager for " + m + " ? ")
#     manager_dict = {
#         'team_name': m,
#         "manager": manager
#     }
#     manager_list.append(manager_dict)
# manager_df = pd.DataFrame(manager_list)
# manager_df.head()
```


```python
# total_draft_df = pd.merge(draft_df, manager_df, how='left', left_on='fantasy_football_team', right_on='team_name')
# total_draft_df = pd.merge(total_draft_df, keeper_df, how='left', on=['player_name'])
# total_draft_df = total_draft_df[['pick', 'player_name', 'player_position', 'player_team', 'salary', 'manager', 'keeper_code']].fillna('')
# total_draft_df.head()
```


```python
# total_draft_df.to_csv('G:\\Mydocs\\Fantasy Football 2020\\FinalDraft2020.csv')
```


```python
draft_df = pd.read_csv('L:\\Marketing\\Yee_Matt\\March Madness\\FF\\FinalDraft2020.csv')
draft_df = draft_df[['pick', 'player_name', 'player_position', 'player_team', 'salary', 'manager', 'keeper_code']]
draft_df.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>DeAndre Hopkins</td>
      <td>WR</td>
      <td>Ari</td>
      <td>75</td>
      <td>Joel</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>Clyde Edwards-Helaire</td>
      <td>RB</td>
      <td>KC</td>
      <td>80</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>Tom Brady</td>
      <td>QB</td>
      <td>TB</td>
      <td>11</td>
      <td>Jake</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>Julio Jones</td>
      <td>WR</td>
      <td>Atl</td>
      <td>78</td>
      <td>Ryan</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>Cam Akers</td>
      <td>RB</td>
      <td>LAR</td>
      <td>33</td>
      <td>Matt</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>




```python
options = webdriver.ChromeOptions()
options.add_argument('--ignore-certificate-errors')

dt_list = []

transaction_list = []
for n in np.arange(0, 10):
    p = str(n*25)
#     print('https://football.fantasysports.yahoo.com/f1/810182/transactions?transactionsfilter=all&count=' + p)
    driver = webdriver.Chrome('L:\\Marketing\\Yee_Matt\\chromedriver.exe', chrome_options=options)
    driver.get('https://football.fantasysports.yahoo.com/f1/810182/transactions?transactionsfilter=all&count=' + p)
    sleep(2)
    transaction_html = driver.page_source
    transaction_soup = BeautifulSoup(transaction_html, "html.parser")
    transaction_table = transaction_soup.findAll('table', {'class': "Table Table-mid Tst-transaction-table"})[0]
    transaction_rows = transaction_table.findAll('tr')

    for n in range(0, len(transaction_rows)):
        tr = transaction_rows[n]
        transaction_details = tr.findAll('td')
        try:
            if (transaction_details[0].findAll('span')[0]['title']) == "Added Player" and (transaction_details[0].findAll('span')[1]['title']) == "Dropped Player":
                added_player_name = transaction_details[1].findAll('div')[0].findAll('a')[0].text.strip()
                added_player_team = transaction_details[1].findAll('div')[0].findAll('span')[0].text.split(' - ')[0].strip()
                added_player_pos = transaction_details[1].findAll('div')[0].findAll('span')[0].text.split(' - ')[1].strip()
                if transaction_details[1].findAll('div')[0].findAll('h6')[0].text.strip() == 'Free Agent' or transaction_details[1].findAll('div')[0].findAll('h6')[0].text.strip() == 'Waiver':
                    transaction_cost = 0
                else:
                    transaction_cost = transaction_details[1].findAll('div')[0].findAll('h6')[0].text.replace('$','').replace('Waiver','').strip()
        #         print(added_player_name, added_player_pos, added_player_team)
                dropped_player_name = transaction_details[1].findAll('div')[1].findAll('a')[0].text.strip()
                dropped_player_pos = transaction_details[1].findAll('div')[1].findAll('span')[0].text.split(' - ')[0].strip()
                dropped_player_team = transaction_details[1].findAll('div')[1].findAll('span')[0].text.split(' - ')[1].strip()
        #         print(dropped_player_name, dropped_player_pos, dropped_player_team)
                ff_team = transaction_details[2].findAll('div')[0].findAll('span')[0].findAll('a')[0].text
                dt = '2020 ' + transaction_details[2].findAll('div')[0].findAll('span')[0].findAll('span')[0].text
#                 print(dt)
                transaction_dict = {
                    'added_player': added_player_name,
                    'added_player_team': added_player_team,
                    'added_player_position': added_player_pos,
                    'dropped_player': dropped_player_name,
                    'dropped_player_team': dropped_player_team,
                    'dropped_player_pos': dropped_player_pos,
                    'ff_team': ff_team,
                    'transaction_time': datetime.strptime(dt, '%Y %b %d, %I:%M %p'),
                    'transaction_cost': int(transaction_cost),
                    'transaction_type': 'add_drop'
                }
#                 print(transaction_dict)
                transaction_list.append(transaction_dict)
        except:
            try:
                if 'F-trade' in transaction_details[0].findAll('span')[0]['class']:
                    t1_player_name = transaction_details[1].findAll('p')[0].findAll('a')[0].text.strip()
                    t1_player_team = transaction_details[1].findAll('p')[0].findAll('span')[0].text.split(' - ')[0].strip()
                    t1_player_pos = transaction_details[1].findAll('p')[0].findAll('span')[0].text.split(' - ')[1].strip()
                    t1_team = transaction_details[3].findAll('div')[0].findAll('span')[0].findAll('a')[0].text.strip()
                    t1_dt = '2020 ' + transaction_details[3].findAll('div')[0].findAll('span')[0].findAll('span')[0].text.strip()
    #                 print(added_player_name, added_player_team, added_player_pos, ff_team, dt_transaction)
                    transaction_dict = {
                        'added_player': t1_player_name,
                        'added_player_team': t1_player_team,
                        'added_player_position': t1_player_pos,
                        'ff_team': t1_team,
                        "transaction_time": datetime.strptime(t1_dt, '%Y %b %d, %I:%M %p'),
                        "transaction_type": 'trade'
                    }
                    transaction_list.append(transaction_dict)
                    trtrade = transaction_rows[n+1]
                    trade_transaction_details = trtrade.findAll('td')
                    t2_player_name = trade_transaction_details[0].findAll('p')[0].findAll('a')[0].text.strip()
                    t2_player_team = trade_transaction_details[0].findAll('p')[0].findAll('span')[0].text.split(' - ')[0].strip()
                    t2_player_pos = trade_transaction_details[0].findAll('p')[0].findAll('span')[0].text.split(' - ')[1].strip()
                    t2_team = trade_transaction_details[2].findAll('div')[0].findAll('span')[0].findAll('a')[0].text.strip()
#                     t2_dt_transaction = trade_transaction_details[2].findAll('div')[0].findAll('span')[0].findAll('span')[0].text.strip()
                    transaction_dict = {
                        'added_player': t2_player_name,
                        'added_player_team': t2_player_team,
                        'added_player_position': t2_player_pos,
                        'ff_team': t2_team,
                        "transaction_time": datetime.strptime(t1_dt, '%Y %b %d, %I:%M %p'),
                        "transaction_type": 'trade'
                    }
                    transaction_list.append(transaction_dict)

            except:
                pass
    driver.close()

transaction_df = pd.DataFrame(transaction_list)
transaction_df = transaction_df.sort_values(by=['transaction_time']).reset_index(drop=True)
transaction_df.head()
```

    C:\Users\MYee\.conda\envs\py36\lib\site-packages\ipykernel_launcher.py:10: DeprecationWarning: use options instead of chrome_options
      # Remove the CWD from sys.path while we load stuff.
    




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>added_player</th>
      <th>added_player_position</th>
      <th>added_player_team</th>
      <th>dropped_player</th>
      <th>dropped_player_pos</th>
      <th>dropped_player_team</th>
      <th>ff_team</th>
      <th>transaction_cost</th>
      <th>transaction_time</th>
      <th>transaction_type</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Bryan Edwards</td>
      <td>WR</td>
      <td>LV</td>
      <td>Tua Tagovailoa</td>
      <td>Mia</td>
      <td>QB</td>
      <td>2 Infinity &amp; Diontae</td>
      <td>1.0</td>
      <td>2020-09-04 00:10:00</td>
      <td>add_drop</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Marquez Valdes-Scantling</td>
      <td>WR</td>
      <td>GB</td>
      <td>Josh Gordon</td>
      <td>Sea</td>
      <td>WR</td>
      <td>Ron Gruden</td>
      <td>0.0</td>
      <td>2020-09-04 00:10:00</td>
      <td>add_drop</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Philadelphia</td>
      <td>DEF</td>
      <td>Phi</td>
      <td>Minnesota</td>
      <td>Min</td>
      <td>DEF</td>
      <td>2 Infinity &amp; Diontae</td>
      <td>0.0</td>
      <td>2020-09-04 00:10:00</td>
      <td>add_drop</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Dan Bailey</td>
      <td>K</td>
      <td>Min</td>
      <td>Cam Newton</td>
      <td>NE</td>
      <td>QB</td>
      <td>No Gurley No Cry</td>
      <td>0.0</td>
      <td>2020-09-04 00:10:00</td>
      <td>add_drop</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Los Angeles</td>
      <td>DEF</td>
      <td>LAR</td>
      <td>Larry Fitzgerald</td>
      <td>Ari</td>
      <td>WR</td>
      <td>Clyde or Die</td>
      <td>0.0</td>
      <td>2020-09-04 00:10:00</td>
      <td>add_drop</td>
    </tr>
  </tbody>
</table>
</div>




```python
manager_list = []
for t in list(set(transaction_df['ff_team'])):
    manager = input("Who is the Manager for " + t + " ? ")
    manager_dict = {
        'team_name': t,
        "manager": manager
    }
    manager_list.append(manager_dict)
manager_df = pd.DataFrame(manager_list)
manager_df
```

    Who is the Manager for Tiz the Law ? Dai
    Who is the Manager for Hoppin 4 Hopkins ? Joel
    Who is the Manager for 2 Infinity & Diontae ? Sean
    Who is the Manager for G ? Jiwei
    Who is the Manager for Chi ShingT's Team ? Chi Shing
    Who is the Manager for Football Team ? Doug
    Who is the Manager for No Gurley No Cry ? Matt
    Who is the Manager for Nags ? Ryan
    Who is the Manager for Pop Drop and Lockett ? Evan
    Who is the Manager for 🍆✊🏼💦 ? Rajiv
    Who is the Manager for Clyde or Die ? Jake
    Who is the Manager for Ron Gruden ? Ron
    




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>manager</th>
      <th>team_name</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Dai</td>
      <td>Tiz the Law</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Joel</td>
      <td>Hoppin 4 Hopkins</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Sean</td>
      <td>2 Infinity &amp; Diontae</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Jiwei</td>
      <td>G</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Chi Shing</td>
      <td>Chi ShingT's Team</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Doug</td>
      <td>Football Team</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Matt</td>
      <td>No Gurley No Cry</td>
    </tr>
    <tr>
      <th>7</th>
      <td>Ryan</td>
      <td>Nags</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Evan</td>
      <td>Pop Drop and Lockett</td>
    </tr>
    <tr>
      <th>9</th>
      <td>Rajiv</td>
      <td>🍆✊🏼💦</td>
    </tr>
    <tr>
      <th>10</th>
      <td>Jake</td>
      <td>Clyde or Die</td>
    </tr>
    <tr>
      <th>11</th>
      <td>Ron</td>
      <td>Ron Gruden</td>
    </tr>
  </tbody>
</table>
</div>




```python
total_transaction = pd.merge(transaction_df, manager_df, how='left', left_on='ff_team', right_on='team_name')
total_transaction.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>added_player</th>
      <th>added_player_position</th>
      <th>added_player_team</th>
      <th>dropped_player</th>
      <th>dropped_player_pos</th>
      <th>dropped_player_team</th>
      <th>ff_team</th>
      <th>transaction_cost</th>
      <th>transaction_time</th>
      <th>transaction_type</th>
      <th>manager</th>
      <th>team_name</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Bryan Edwards</td>
      <td>WR</td>
      <td>LV</td>
      <td>Tua Tagovailoa</td>
      <td>Mia</td>
      <td>QB</td>
      <td>2 Infinity &amp; Diontae</td>
      <td>1.0</td>
      <td>2020-09-04 00:10:00</td>
      <td>add_drop</td>
      <td>Sean</td>
      <td>2 Infinity &amp; Diontae</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Marquez Valdes-Scantling</td>
      <td>WR</td>
      <td>GB</td>
      <td>Josh Gordon</td>
      <td>Sea</td>
      <td>WR</td>
      <td>Ron Gruden</td>
      <td>0.0</td>
      <td>2020-09-04 00:10:00</td>
      <td>add_drop</td>
      <td>Ron</td>
      <td>Ron Gruden</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Philadelphia</td>
      <td>DEF</td>
      <td>Phi</td>
      <td>Minnesota</td>
      <td>Min</td>
      <td>DEF</td>
      <td>2 Infinity &amp; Diontae</td>
      <td>0.0</td>
      <td>2020-09-04 00:10:00</td>
      <td>add_drop</td>
      <td>Sean</td>
      <td>2 Infinity &amp; Diontae</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Dan Bailey</td>
      <td>K</td>
      <td>Min</td>
      <td>Cam Newton</td>
      <td>NE</td>
      <td>QB</td>
      <td>No Gurley No Cry</td>
      <td>0.0</td>
      <td>2020-09-04 00:10:00</td>
      <td>add_drop</td>
      <td>Matt</td>
      <td>No Gurley No Cry</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Los Angeles</td>
      <td>DEF</td>
      <td>LAR</td>
      <td>Larry Fitzgerald</td>
      <td>Ari</td>
      <td>WR</td>
      <td>Clyde or Die</td>
      <td>0.0</td>
      <td>2020-09-04 00:10:00</td>
      <td>add_drop</td>
      <td>Jake</td>
      <td>Clyde or Die</td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df = pd.read_csv('L:\\Marketing\\Yee_Matt\\March Madness\\FF\\FinalDraft2020.csv')
draft_df = draft_df[['pick', 'player_name', 'player_position', 'player_team', 'salary', 'manager', 'keeper_code']]
draft_df


for it, rt in total_transaction.iterrows():
    if rt['transaction_type'] == 'add_drop':
        adi = list(draft_df['player_name']).index(rt['dropped_player'])
#         print(draft_df.at[adi, 'player_name'])
        draft_df.at[adi, 'player_name'] = rt['added_player']
        draft_df.at[adi, 'player_position'] = rt['added_player_team']
        draft_df.at[adi, 'player_team'] = rt['added_player_team']
        draft_df.at[adi, 'salary'] = rt['transaction_cost']
        draft_df.at[adi, 'keeper_code'] = ''
#         print(draft_df.at[adi, 'player_name'])
    elif rt['transaction_type'] == 'trade':
        ti = list(draft_df['player_name']).index(rt['added_player'])
        draft_df.at[ti, 'manager'] = rt['manager']
draft_df = draft_df.sort_values(by=['manager', 'salary'], ascending=[True, False]).reset_index(drop=True).fillna('')    
draft_df.to_csv('L:\\Marketing\\Yee_Matt\\March Madness\\FF\\FF_2020_Rosters.csv')
draft_df    
    
    
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>6</td>
      <td>Josh Jacobs</td>
      <td>RB</td>
      <td>LV</td>
      <td>68</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>1</th>
      <td>185</td>
      <td>Joe Mixon</td>
      <td>RB</td>
      <td>Cin</td>
      <td>63</td>
      <td>Chi Shing</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>2</th>
      <td>9</td>
      <td>Odell Beckham Jr.</td>
      <td>WR</td>
      <td>Cle</td>
      <td>53</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>3</th>
      <td>22</td>
      <td>Leonard Fournette</td>
      <td>RB</td>
      <td>TB</td>
      <td>33</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>4</th>
      <td>184</td>
      <td>Hunter Henry</td>
      <td>TE</td>
      <td>LAC</td>
      <td>21</td>
      <td>Chi Shing</td>
      <td>D</td>
    </tr>
    <tr>
      <th>5</th>
      <td>56</td>
      <td>Marvin Jones Jr.</td>
      <td>WR</td>
      <td>Det</td>
      <td>18</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>6</th>
      <td>65</td>
      <td>CeeDee Lamb</td>
      <td>WR</td>
      <td>Dal</td>
      <td>18</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>7</th>
      <td>187</td>
      <td>Patrick Mahomes</td>
      <td>QB</td>
      <td>KC</td>
      <td>15</td>
      <td>Chi Shing</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>8</th>
      <td>87</td>
      <td>Christian Kirk</td>
      <td>WR</td>
      <td>Ari</td>
      <td>11</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>9</th>
      <td>186</td>
      <td>John Brown</td>
      <td>WR</td>
      <td>Buf</td>
      <td>8</td>
      <td>Chi Shing</td>
      <td>D</td>
    </tr>
    <tr>
      <th>10</th>
      <td>115</td>
      <td>Tevin Coleman</td>
      <td>RB</td>
      <td>SF</td>
      <td>2</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>11</th>
      <td>79</td>
      <td>Cole Beasley</td>
      <td>WR</td>
      <td>Buf</td>
      <td>1</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>12</th>
      <td>110</td>
      <td>Tampa Bay</td>
      <td>DEF</td>
      <td>TB</td>
      <td>1</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>13</th>
      <td>128</td>
      <td>Robby Anderson</td>
      <td>WR</td>
      <td>Car</td>
      <td>1</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>14</th>
      <td>100</td>
      <td>Michael Badgley</td>
      <td>LAC</td>
      <td>LAC</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>15</th>
      <td>119</td>
      <td>Benny Snell Jr.</td>
      <td>Pit</td>
      <td>Pit</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>16</th>
      <td>174</td>
      <td>Davante Adams</td>
      <td>WR</td>
      <td>GB</td>
      <td>47</td>
      <td>Dai</td>
      <td>ABCD</td>
    </tr>
    <tr>
      <th>17</th>
      <td>27</td>
      <td>Zach Ertz</td>
      <td>TE</td>
      <td>Phi</td>
      <td>45</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>18</th>
      <td>29</td>
      <td>Keenan Allen</td>
      <td>WR</td>
      <td>LAC</td>
      <td>39</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>19</th>
      <td>173</td>
      <td>Miles Sanders</td>
      <td>RB</td>
      <td>Phi</td>
      <td>34</td>
      <td>Dai</td>
      <td>D</td>
    </tr>
    <tr>
      <th>20</th>
      <td>34</td>
      <td>J.K. Dobbins</td>
      <td>RB</td>
      <td>Bal</td>
      <td>27</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>21</th>
      <td>175</td>
      <td>DJ Moore</td>
      <td>WR</td>
      <td>Car</td>
      <td>17</td>
      <td>Dai</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>22</th>
      <td>82</td>
      <td>Zack Moss</td>
      <td>RB</td>
      <td>Buf</td>
      <td>11</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>23</th>
      <td>35</td>
      <td>Joshua Kelley</td>
      <td>RB</td>
      <td>LAC</td>
      <td>10</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>24</th>
      <td>84</td>
      <td>Jerry Jeudy</td>
      <td>WR</td>
      <td>Den</td>
      <td>10</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>25</th>
      <td>172</td>
      <td>Raheem Mostert</td>
      <td>RB</td>
      <td>SF</td>
      <td>10</td>
      <td>Dai</td>
      <td>D</td>
    </tr>
    <tr>
      <th>26</th>
      <td>59</td>
      <td>Joe Burrow</td>
      <td>QB</td>
      <td>Cin</td>
      <td>6</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>27</th>
      <td>83</td>
      <td>Denver</td>
      <td>Den</td>
      <td>Den</td>
      <td>2</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>28</th>
      <td>66</td>
      <td>Anthony Miller</td>
      <td>Chi</td>
      <td>Chi</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>29</th>
      <td>68</td>
      <td>Mason Crosby</td>
      <td>GB</td>
      <td>GB</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>30</th>
      <td>75</td>
      <td>La'Mical Perine</td>
      <td>NYJ</td>
      <td>NYJ</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>31</th>
      <td>76</td>
      <td>Anthony McFarland Jr.</td>
      <td>Pit</td>
      <td>Pit</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>32</th>
      <td>7</td>
      <td>Tyreek Hill</td>
      <td>WR</td>
      <td>KC</td>
      <td>78</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>33</th>
      <td>11</td>
      <td>Todd Gurley II</td>
      <td>RB</td>
      <td>Atl</td>
      <td>53</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>34</th>
      <td>18</td>
      <td>Mark Ingram II</td>
      <td>RB</td>
      <td>Bal</td>
      <td>52</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>35</th>
      <td>89</td>
      <td>James White</td>
      <td>RB</td>
      <td>NE</td>
      <td>11</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>36</th>
      <td>88</td>
      <td>Deebo Samuel</td>
      <td>WR</td>
      <td>SF</td>
      <td>10</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>37</th>
      <td>179</td>
      <td>Lamar Jackson</td>
      <td>QB</td>
      <td>Bal</td>
      <td>10</td>
      <td>Doug</td>
      <td>D</td>
    </tr>
    <tr>
      <th>38</th>
      <td>98</td>
      <td>Mo Alie-Cox</td>
      <td>Ind</td>
      <td>Ind</td>
      <td>8</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>39</th>
      <td>178</td>
      <td>DeVante Parker</td>
      <td>WR</td>
      <td>Mia</td>
      <td>6</td>
      <td>Doug</td>
      <td>D</td>
    </tr>
    <tr>
      <th>40</th>
      <td>108</td>
      <td>Eric Ebron</td>
      <td>Pit</td>
      <td>Pit</td>
      <td>5</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>41</th>
      <td>86</td>
      <td>Harrison Butker</td>
      <td>K</td>
      <td>KC</td>
      <td>3</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>42</th>
      <td>62</td>
      <td>Adrian Peterson</td>
      <td>RB</td>
      <td>Det</td>
      <td>2</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>43</th>
      <td>117</td>
      <td>Chase Edmonds</td>
      <td>Ari</td>
      <td>Ari</td>
      <td>2</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>44</th>
      <td>121</td>
      <td>Los Angeles</td>
      <td>LAR</td>
      <td>LAR</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>45</th>
      <td>126</td>
      <td>Andy Isabella</td>
      <td>Ari</td>
      <td>Ari</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>46</th>
      <td>135</td>
      <td>Jeff Wilson Jr.</td>
      <td>SF</td>
      <td>SF</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>47</th>
      <td>177</td>
      <td>Randall Cobb</td>
      <td>Hou</td>
      <td>Hou</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>48</th>
      <td>15</td>
      <td>David Johnson</td>
      <td>RB</td>
      <td>Hou</td>
      <td>59</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>49</th>
      <td>171</td>
      <td>Chris Godwin</td>
      <td>WR</td>
      <td>TB</td>
      <td>45</td>
      <td>Evan</td>
      <td>D</td>
    </tr>
    <tr>
      <th>50</th>
      <td>43</td>
      <td>Marquise Brown</td>
      <td>WR</td>
      <td>Bal</td>
      <td>34</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>51</th>
      <td>10</td>
      <td>Tyler Higbee</td>
      <td>TE</td>
      <td>LAR</td>
      <td>22</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>52</th>
      <td>73</td>
      <td>Antonio Gibson</td>
      <td>RB</td>
      <td>Was</td>
      <td>22</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>53</th>
      <td>170</td>
      <td>Tyler Lockett</td>
      <td>WR</td>
      <td>Sea</td>
      <td>21</td>
      <td>Evan</td>
      <td>BCD</td>
    </tr>
    <tr>
      <th>54</th>
      <td>41</td>
      <td>Julian Edelman</td>
      <td>WR</td>
      <td>NE</td>
      <td>19</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>55</th>
      <td>55</td>
      <td>Josh Allen</td>
      <td>QB</td>
      <td>Buf</td>
      <td>18</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>56</th>
      <td>64</td>
      <td>Tarik Cohen</td>
      <td>RB</td>
      <td>Chi</td>
      <td>17</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>57</th>
      <td>168</td>
      <td>Kyler Murray</td>
      <td>QB</td>
      <td>Ari</td>
      <td>17</td>
      <td>Evan</td>
      <td>D</td>
    </tr>
    <tr>
      <th>58</th>
      <td>72</td>
      <td>Austin Hooper</td>
      <td>TE</td>
      <td>Cle</td>
      <td>13</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>59</th>
      <td>52</td>
      <td>Kerryon Johnson</td>
      <td>RB</td>
      <td>Det</td>
      <td>12</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>60</th>
      <td>51</td>
      <td>San Francisco</td>
      <td>DEF</td>
      <td>SF</td>
      <td>10</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>61</th>
      <td>58</td>
      <td>Sammy Watkins</td>
      <td>KC</td>
      <td>KC</td>
      <td>7</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>62</th>
      <td>169</td>
      <td>Ronald Jones II</td>
      <td>RB</td>
      <td>TB</td>
      <td>7</td>
      <td>Evan</td>
      <td>D</td>
    </tr>
    <tr>
      <th>63</th>
      <td>47</td>
      <td>Greg Zuerlein</td>
      <td>K</td>
      <td>Dal</td>
      <td>4</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>64</th>
      <td>2</td>
      <td>Clyde Edwards-Helaire</td>
      <td>RB</td>
      <td>KC</td>
      <td>80</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>65</th>
      <td>180</td>
      <td>Ezekiel Elliott</td>
      <td>RB</td>
      <td>Dal</td>
      <td>71</td>
      <td>Jake</td>
      <td>BCD</td>
    </tr>
    <tr>
      <th>66</th>
      <td>16</td>
      <td>Darren Waller</td>
      <td>TE</td>
      <td>LV</td>
      <td>51</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>67</th>
      <td>183</td>
      <td>Michael Thomas</td>
      <td>WR</td>
      <td>NO</td>
      <td>38</td>
      <td>Jake</td>
      <td>ABCD</td>
    </tr>
    <tr>
      <th>68</th>
      <td>181</td>
      <td>JuJu Smith-Schuster</td>
      <td>WR</td>
      <td>Pit</td>
      <td>21</td>
      <td>Jake</td>
      <td>BCD</td>
    </tr>
    <tr>
      <th>69</th>
      <td>182</td>
      <td>Cooper Kupp</td>
      <td>WR</td>
      <td>LAR</td>
      <td>17</td>
      <td>Jake</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>70</th>
      <td>130</td>
      <td>Marquez Valdes-Scantling</td>
      <td>GB</td>
      <td>GB</td>
      <td>13</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>71</th>
      <td>142</td>
      <td>Russell Gage</td>
      <td>Atl</td>
      <td>Atl</td>
      <td>12</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>72</th>
      <td>3</td>
      <td>Tom Brady</td>
      <td>QB</td>
      <td>TB</td>
      <td>11</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>73</th>
      <td>30</td>
      <td>Sony Michel</td>
      <td>RB</td>
      <td>NE</td>
      <td>7</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>74</th>
      <td>112</td>
      <td>Corey Davis</td>
      <td>Ten</td>
      <td>Ten</td>
      <td>6</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>75</th>
      <td>95</td>
      <td>Jonnu Smith</td>
      <td>TE</td>
      <td>Ten</td>
      <td>3</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>76</th>
      <td>102</td>
      <td>Zane Gonzalez</td>
      <td>K</td>
      <td>Ari</td>
      <td>1</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>77</th>
      <td>46</td>
      <td>Jared Goff</td>
      <td>LAR</td>
      <td>LAR</td>
      <td>0</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>78</th>
      <td>81</td>
      <td>Malcolm Brown</td>
      <td>LAR</td>
      <td>LAR</td>
      <td>0</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>79</th>
      <td>139</td>
      <td>Arizona</td>
      <td>Ari</td>
      <td>Ari</td>
      <td>0</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>80</th>
      <td>166</td>
      <td>Calvin Ridley</td>
      <td>WR</td>
      <td>Atl</td>
      <td>41</td>
      <td>Jiwei</td>
      <td>D</td>
    </tr>
    <tr>
      <th>81</th>
      <td>37</td>
      <td>D'Andre Swift</td>
      <td>RB</td>
      <td>Det</td>
      <td>39</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>82</th>
      <td>165</td>
      <td>Chris Carson</td>
      <td>RB</td>
      <td>Sea</td>
      <td>37</td>
      <td>Jiwei</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>83</th>
      <td>23</td>
      <td>T.Y. Hilton</td>
      <td>WR</td>
      <td>Ind</td>
      <td>36</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>84</th>
      <td>12</td>
      <td>Devonta Freeman</td>
      <td>NYG</td>
      <td>NYG</td>
      <td>27</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>85</th>
      <td>164</td>
      <td>Kenyan Drake</td>
      <td>RB</td>
      <td>Ari</td>
      <td>25</td>
      <td>Jiwei</td>
      <td>D</td>
    </tr>
    <tr>
      <th>86</th>
      <td>33</td>
      <td>A.J. Green</td>
      <td>WR</td>
      <td>Cin</td>
      <td>22</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>87</th>
      <td>49</td>
      <td>Hayden Hurst</td>
      <td>TE</td>
      <td>Atl</td>
      <td>20</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>88</th>
      <td>77</td>
      <td>Tee Higgins</td>
      <td>Cin</td>
      <td>Cin</td>
      <td>12</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>89</th>
      <td>167</td>
      <td>Dak Prescott</td>
      <td>QB</td>
      <td>Dal</td>
      <td>10</td>
      <td>Jiwei</td>
      <td>D</td>
    </tr>
    <tr>
      <th>90</th>
      <td>61</td>
      <td>Justin Tucker</td>
      <td>K</td>
      <td>Bal</td>
      <td>5</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>91</th>
      <td>94</td>
      <td>Justin Jefferson</td>
      <td>WR</td>
      <td>Min</td>
      <td>4</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>92</th>
      <td>96</td>
      <td>Mike Gesicki</td>
      <td>TE</td>
      <td>Mia</td>
      <td>4</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>93</th>
      <td>80</td>
      <td>Baltimore</td>
      <td>DEF</td>
      <td>Bal</td>
      <td>3</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>94</th>
      <td>104</td>
      <td>Allen Lazard</td>
      <td>WR</td>
      <td>GB</td>
      <td>1</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>95</th>
      <td>140</td>
      <td>Boston Scott</td>
      <td>RB</td>
      <td>Phi</td>
      <td>1</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>96</th>
      <td>1</td>
      <td>DeAndre Hopkins</td>
      <td>WR</td>
      <td>Ari</td>
      <td>75</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>97</th>
      <td>19</td>
      <td>Mike Evans</td>
      <td>WR</td>
      <td>TB</td>
      <td>67</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>98</th>
      <td>152</td>
      <td>David Montgomery</td>
      <td>RB</td>
      <td>Chi</td>
      <td>47</td>
      <td>Joel</td>
      <td>D</td>
    </tr>
    <tr>
      <th>99</th>
      <td>45</td>
      <td>Matt Ryan</td>
      <td>QB</td>
      <td>Atl</td>
      <td>26</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>100</th>
      <td>57</td>
      <td>Will Fuller V</td>
      <td>WR</td>
      <td>Hou</td>
      <td>22</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>101</th>
      <td>21</td>
      <td>Jared Cook</td>
      <td>TE</td>
      <td>NO</td>
      <td>17</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>102</th>
      <td>153</td>
      <td>James Conner</td>
      <td>RB</td>
      <td>Pit</td>
      <td>17</td>
      <td>Joel</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>103</th>
      <td>154</td>
      <td>Devin Singletary</td>
      <td>RB</td>
      <td>Buf</td>
      <td>13</td>
      <td>Joel</td>
      <td>D</td>
    </tr>
    <tr>
      <th>104</th>
      <td>129</td>
      <td>Darrell Henderson Jr.</td>
      <td>LAR</td>
      <td>LAR</td>
      <td>11</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>105</th>
      <td>48</td>
      <td>T.J. Hockenson</td>
      <td>TE</td>
      <td>Det</td>
      <td>5</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>106</th>
      <td>155</td>
      <td>Jamison Crowder</td>
      <td>WR</td>
      <td>NYJ</td>
      <td>5</td>
      <td>Joel</td>
      <td>D</td>
    </tr>
    <tr>
      <th>107</th>
      <td>69</td>
      <td>Matt Prater</td>
      <td>K</td>
      <td>Det</td>
      <td>1</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>108</th>
      <td>101</td>
      <td>Pittsburgh</td>
      <td>DEF</td>
      <td>Pit</td>
      <td>1</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>109</th>
      <td>111</td>
      <td>Golden Tate</td>
      <td>WR</td>
      <td>NYG</td>
      <td>1</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>110</th>
      <td>91</td>
      <td>Greg Ward</td>
      <td>Phi</td>
      <td>Phi</td>
      <td>0</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>111</th>
      <td>120</td>
      <td>Nyheim Hines</td>
      <td>Ind</td>
      <td>Ind</td>
      <td>0</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>112</th>
      <td>113</td>
      <td>Saquon Barkley</td>
      <td>NYG</td>
      <td>NYG</td>
      <td>72</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>113</th>
      <td>13</td>
      <td>Jonathan Taylor</td>
      <td>RB</td>
      <td>Ind</td>
      <td>59</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>114</th>
      <td>158</td>
      <td>Adam Thielen</td>
      <td>WR</td>
      <td>Min</td>
      <td>42</td>
      <td>Matt</td>
      <td>BCD</td>
    </tr>
    <tr>
      <th>115</th>
      <td>159</td>
      <td>Allen Robinson II</td>
      <td>WR</td>
      <td>Chi</td>
      <td>34</td>
      <td>Matt</td>
      <td>D</td>
    </tr>
    <tr>
      <th>116</th>
      <td>5</td>
      <td>Cam Akers</td>
      <td>RB</td>
      <td>LAR</td>
      <td>33</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>117</th>
      <td>38</td>
      <td>Russell Wilson</td>
      <td>QB</td>
      <td>Sea</td>
      <td>33</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>118</th>
      <td>44</td>
      <td>Jarvis Landry</td>
      <td>WR</td>
      <td>Cle</td>
      <td>32</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>119</th>
      <td>54</td>
      <td>Emmanuel Sanders</td>
      <td>WR</td>
      <td>NO</td>
      <td>18</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>120</th>
      <td>157</td>
      <td>Aaron Jones</td>
      <td>RB</td>
      <td>GB</td>
      <td>16</td>
      <td>Matt</td>
      <td>BCD</td>
    </tr>
    <tr>
      <th>121</th>
      <td>156</td>
      <td>Mark Andrews</td>
      <td>TE</td>
      <td>Bal</td>
      <td>12</td>
      <td>Matt</td>
      <td>D</td>
    </tr>
    <tr>
      <th>122</th>
      <td>67</td>
      <td>Aaron Rodgers</td>
      <td>QB</td>
      <td>GB</td>
      <td>10</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>123</th>
      <td>20</td>
      <td>Carlos Hyde</td>
      <td>RB</td>
      <td>Sea</td>
      <td>4</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>124</th>
      <td>106</td>
      <td>New England</td>
      <td>DEF</td>
      <td>NE</td>
      <td>3</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>125</th>
      <td>131</td>
      <td>N'Keal Harry</td>
      <td>WR</td>
      <td>NE</td>
      <td>1</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>126</th>
      <td>103</td>
      <td>Jacksonville</td>
      <td>Jax</td>
      <td>Jax</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>127</th>
      <td>122</td>
      <td>Rodrigo Blankenship</td>
      <td>Ind</td>
      <td>Ind</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>128</th>
      <td>25</td>
      <td>Amari Cooper</td>
      <td>WR</td>
      <td>Dal</td>
      <td>56</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>129</th>
      <td>192</td>
      <td>Derrick Henry</td>
      <td>RB</td>
      <td>Ten</td>
      <td>49</td>
      <td>Rajiv</td>
      <td>D</td>
    </tr>
    <tr>
      <th>130</th>
      <td>8</td>
      <td>Melvin Gordon III</td>
      <td>RB</td>
      <td>Den</td>
      <td>47</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>131</th>
      <td>26</td>
      <td>Terry McLaurin</td>
      <td>WR</td>
      <td>Was</td>
      <td>44</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>132</th>
      <td>28</td>
      <td>Evan Engram</td>
      <td>TE</td>
      <td>NYG</td>
      <td>35</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>133</th>
      <td>32</td>
      <td>Michael Gallup</td>
      <td>WR</td>
      <td>Dal</td>
      <td>28</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>134</th>
      <td>42</td>
      <td>Drew Brees</td>
      <td>QB</td>
      <td>NO</td>
      <td>23</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>135</th>
      <td>24</td>
      <td>Phillip Lindsay</td>
      <td>RB</td>
      <td>Den</td>
      <td>21</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>136</th>
      <td>90</td>
      <td>Darius Slayton</td>
      <td>WR</td>
      <td>NYG</td>
      <td>10</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>137</th>
      <td>124</td>
      <td>Robbie Gould</td>
      <td>K</td>
      <td>SF</td>
      <td>1</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>138</th>
      <td>132</td>
      <td>Hunter Renfrow</td>
      <td>WR</td>
      <td>LV</td>
      <td>1</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>139</th>
      <td>143</td>
      <td>Alexander Mattison</td>
      <td>RB</td>
      <td>Min</td>
      <td>1</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>140</th>
      <td>145</td>
      <td>Justin Jackson</td>
      <td>RB</td>
      <td>LAC</td>
      <td>1</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>141</th>
      <td>146</td>
      <td>Jerick McKinnon</td>
      <td>RB</td>
      <td>SF</td>
      <td>1</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>142</th>
      <td>137</td>
      <td>Kansas City</td>
      <td>KC</td>
      <td>KC</td>
      <td>0</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>143</th>
      <td>147</td>
      <td>Jimmy Graham</td>
      <td>Chi</td>
      <td>Chi</td>
      <td>0</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>144</th>
      <td>148</td>
      <td>Dalvin Cook</td>
      <td>RB</td>
      <td>Min</td>
      <td>79</td>
      <td>Ron</td>
      <td>D</td>
    </tr>
    <tr>
      <th>145</th>
      <td>14</td>
      <td>Le'Veon Bell</td>
      <td>RB</td>
      <td>NYJ</td>
      <td>48</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>146</th>
      <td>17</td>
      <td>Stefon Diggs</td>
      <td>WR</td>
      <td>Buf</td>
      <td>41</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>147</th>
      <td>40</td>
      <td>Tyler Boyd</td>
      <td>WR</td>
      <td>Cin</td>
      <td>30</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>148</th>
      <td>149</td>
      <td>Austin Ekeler</td>
      <td>RB</td>
      <td>LAC</td>
      <td>15</td>
      <td>Ron</td>
      <td>D</td>
    </tr>
    <tr>
      <th>149</th>
      <td>176</td>
      <td>DJ Chark Jr.</td>
      <td>WR</td>
      <td>Jax</td>
      <td>14</td>
      <td>Ron</td>
      <td>D</td>
    </tr>
    <tr>
      <th>150</th>
      <td>151</td>
      <td>Courtland Sutton</td>
      <td>WR</td>
      <td>Den</td>
      <td>10</td>
      <td>Ron</td>
      <td>D</td>
    </tr>
    <tr>
      <th>151</th>
      <td>36</td>
      <td>Matthew Stafford</td>
      <td>QB</td>
      <td>Det</td>
      <td>6</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>152</th>
      <td>123</td>
      <td>Myles Gaskin</td>
      <td>Mia</td>
      <td>Mia</td>
      <td>6</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>153</th>
      <td>150</td>
      <td>DK Metcalf</td>
      <td>WR</td>
      <td>Sea</td>
      <td>5</td>
      <td>Ron</td>
      <td>D</td>
    </tr>
    <tr>
      <th>154</th>
      <td>63</td>
      <td>Wil Lutz</td>
      <td>K</td>
      <td>NO</td>
      <td>3</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>155</th>
      <td>85</td>
      <td>Indianapolis</td>
      <td>Ind</td>
      <td>Ind</td>
      <td>1</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>156</th>
      <td>50</td>
      <td>Laviska Shenault Jr.</td>
      <td>Jax</td>
      <td>Jax</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>157</th>
      <td>74</td>
      <td>Dallas Goedert</td>
      <td>Phi</td>
      <td>Phi</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>158</th>
      <td>105</td>
      <td>Scotty Miller</td>
      <td>TB</td>
      <td>TB</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>159</th>
      <td>114</td>
      <td>Logan Thomas</td>
      <td>Was</td>
      <td>Was</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>160</th>
      <td>4</td>
      <td>Julio Jones</td>
      <td>WR</td>
      <td>Atl</td>
      <td>78</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>161</th>
      <td>189</td>
      <td>Travis Kelce</td>
      <td>TE</td>
      <td>KC</td>
      <td>64</td>
      <td>Ryan</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>162</th>
      <td>188</td>
      <td>Kenny Golladay</td>
      <td>WR</td>
      <td>Det</td>
      <td>46</td>
      <td>Ryan</td>
      <td>D</td>
    </tr>
    <tr>
      <th>163</th>
      <td>39</td>
      <td>Deshaun Watson</td>
      <td>QB</td>
      <td>Hou</td>
      <td>44</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>164</th>
      <td>191</td>
      <td>Nick Chubb</td>
      <td>RB</td>
      <td>Cle</td>
      <td>15</td>
      <td>Ryan</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>165</th>
      <td>93</td>
      <td>Gardner Minshew II</td>
      <td>Jax</td>
      <td>Jax</td>
      <td>9</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>166</th>
      <td>53</td>
      <td>Dion Lewis</td>
      <td>NYG</td>
      <td>NYG</td>
      <td>7</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>167</th>
      <td>190</td>
      <td>Kareem Hunt</td>
      <td>RB</td>
      <td>Cle</td>
      <td>6</td>
      <td>Ryan</td>
      <td>D</td>
    </tr>
    <tr>
      <th>168</th>
      <td>71</td>
      <td>Brandon Aiyuk</td>
      <td>WR</td>
      <td>SF</td>
      <td>4</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>169</th>
      <td>118</td>
      <td>Michael Pittman Jr.</td>
      <td>WR</td>
      <td>Ind</td>
      <td>2</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>170</th>
      <td>97</td>
      <td>Noah Fant</td>
      <td>TE</td>
      <td>Den</td>
      <td>1</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>171</th>
      <td>107</td>
      <td>Jalen Reagor</td>
      <td>WR</td>
      <td>Phi</td>
      <td>1</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>172</th>
      <td>116</td>
      <td>New Orleans</td>
      <td>DEF</td>
      <td>NO</td>
      <td>1</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>173</th>
      <td>125</td>
      <td>Jason Myers</td>
      <td>Sea</td>
      <td>Sea</td>
      <td>1</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>174</th>
      <td>133</td>
      <td>Tony Pollard</td>
      <td>RB</td>
      <td>Dal</td>
      <td>1</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>175</th>
      <td>92</td>
      <td>Chase Claypool</td>
      <td>Pit</td>
      <td>Pit</td>
      <td>0</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>176</th>
      <td>160</td>
      <td>Christian McCaffrey</td>
      <td>RB</td>
      <td>Car</td>
      <td>99</td>
      <td>Sean</td>
      <td>D</td>
    </tr>
    <tr>
      <th>177</th>
      <td>31</td>
      <td>Robert Woods</td>
      <td>WR</td>
      <td>LAR</td>
      <td>57</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>178</th>
      <td>138</td>
      <td>Mike Davis</td>
      <td>Car</td>
      <td>Car</td>
      <td>33</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>179</th>
      <td>162</td>
      <td>Alvin Kamara</td>
      <td>RB</td>
      <td>NO</td>
      <td>25</td>
      <td>Sean</td>
      <td>BCD</td>
    </tr>
    <tr>
      <th>180</th>
      <td>161</td>
      <td>George Kittle</td>
      <td>TE</td>
      <td>SF</td>
      <td>18</td>
      <td>Sean</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>181</th>
      <td>60</td>
      <td>Diontae Johnson</td>
      <td>WR</td>
      <td>Pit</td>
      <td>17</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>182</th>
      <td>163</td>
      <td>A.J. Brown</td>
      <td>WR</td>
      <td>Ten</td>
      <td>11</td>
      <td>Sean</td>
      <td>D</td>
    </tr>
    <tr>
      <th>183</th>
      <td>78</td>
      <td>Mecole Hardman</td>
      <td>KC</td>
      <td>KC</td>
      <td>4</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>184</th>
      <td>109</td>
      <td>Dalton Schultz</td>
      <td>Dal</td>
      <td>Dal</td>
      <td>3</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>185</th>
      <td>136</td>
      <td>Parris Campbell</td>
      <td>WR</td>
      <td>Ind</td>
      <td>1</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>186</th>
      <td>144</td>
      <td>Seattle</td>
      <td>Sea</td>
      <td>Sea</td>
      <td>1</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>187</th>
      <td>70</td>
      <td>Damien Harris</td>
      <td>NE</td>
      <td>NE</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>188</th>
      <td>99</td>
      <td>James Robinson</td>
      <td>Jax</td>
      <td>Jax</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>189</th>
      <td>127</td>
      <td>Preston Williams</td>
      <td>Mia</td>
      <td>Mia</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>190</th>
      <td>134</td>
      <td>Cam Newton</td>
      <td>NE</td>
      <td>NE</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>191</th>
      <td>141</td>
      <td>Joey Slye</td>
      <td>Car</td>
      <td>Car</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Chi Shing']
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>6</td>
      <td>Josh Jacobs</td>
      <td>RB</td>
      <td>LV</td>
      <td>68</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>1</th>
      <td>185</td>
      <td>Joe Mixon</td>
      <td>RB</td>
      <td>Cin</td>
      <td>63</td>
      <td>Chi Shing</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>2</th>
      <td>9</td>
      <td>Odell Beckham Jr.</td>
      <td>WR</td>
      <td>Cle</td>
      <td>53</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>3</th>
      <td>22</td>
      <td>Leonard Fournette</td>
      <td>RB</td>
      <td>TB</td>
      <td>33</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>4</th>
      <td>184</td>
      <td>Hunter Henry</td>
      <td>TE</td>
      <td>LAC</td>
      <td>21</td>
      <td>Chi Shing</td>
      <td>D</td>
    </tr>
    <tr>
      <th>5</th>
      <td>56</td>
      <td>Marvin Jones Jr.</td>
      <td>WR</td>
      <td>Det</td>
      <td>18</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>6</th>
      <td>65</td>
      <td>CeeDee Lamb</td>
      <td>WR</td>
      <td>Dal</td>
      <td>18</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>7</th>
      <td>187</td>
      <td>Patrick Mahomes</td>
      <td>QB</td>
      <td>KC</td>
      <td>15</td>
      <td>Chi Shing</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>8</th>
      <td>87</td>
      <td>Christian Kirk</td>
      <td>WR</td>
      <td>Ari</td>
      <td>11</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>9</th>
      <td>186</td>
      <td>John Brown</td>
      <td>WR</td>
      <td>Buf</td>
      <td>8</td>
      <td>Chi Shing</td>
      <td>D</td>
    </tr>
    <tr>
      <th>10</th>
      <td>115</td>
      <td>Tevin Coleman</td>
      <td>RB</td>
      <td>SF</td>
      <td>2</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>11</th>
      <td>79</td>
      <td>Cole Beasley</td>
      <td>WR</td>
      <td>Buf</td>
      <td>1</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>12</th>
      <td>110</td>
      <td>Tampa Bay</td>
      <td>DEF</td>
      <td>TB</td>
      <td>1</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>13</th>
      <td>128</td>
      <td>Robby Anderson</td>
      <td>WR</td>
      <td>Car</td>
      <td>1</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>14</th>
      <td>100</td>
      <td>Michael Badgley</td>
      <td>LAC</td>
      <td>LAC</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>15</th>
      <td>119</td>
      <td>Benny Snell Jr.</td>
      <td>Pit</td>
      <td>Pit</td>
      <td>0</td>
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
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>174</td>
      <td>Davante Adams</td>
      <td>WR</td>
      <td>GB</td>
      <td>47</td>
      <td>Dai</td>
      <td>ABCD</td>
    </tr>
    <tr>
      <th>17</th>
      <td>27</td>
      <td>Zach Ertz</td>
      <td>TE</td>
      <td>Phi</td>
      <td>45</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>18</th>
      <td>29</td>
      <td>Keenan Allen</td>
      <td>WR</td>
      <td>LAC</td>
      <td>39</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>19</th>
      <td>173</td>
      <td>Miles Sanders</td>
      <td>RB</td>
      <td>Phi</td>
      <td>34</td>
      <td>Dai</td>
      <td>D</td>
    </tr>
    <tr>
      <th>20</th>
      <td>34</td>
      <td>J.K. Dobbins</td>
      <td>RB</td>
      <td>Bal</td>
      <td>27</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>21</th>
      <td>175</td>
      <td>DJ Moore</td>
      <td>WR</td>
      <td>Car</td>
      <td>17</td>
      <td>Dai</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>22</th>
      <td>82</td>
      <td>Zack Moss</td>
      <td>RB</td>
      <td>Buf</td>
      <td>11</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>23</th>
      <td>35</td>
      <td>Joshua Kelley</td>
      <td>RB</td>
      <td>LAC</td>
      <td>10</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>24</th>
      <td>84</td>
      <td>Jerry Jeudy</td>
      <td>WR</td>
      <td>Den</td>
      <td>10</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>25</th>
      <td>172</td>
      <td>Raheem Mostert</td>
      <td>RB</td>
      <td>SF</td>
      <td>10</td>
      <td>Dai</td>
      <td>D</td>
    </tr>
    <tr>
      <th>26</th>
      <td>59</td>
      <td>Joe Burrow</td>
      <td>QB</td>
      <td>Cin</td>
      <td>6</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>27</th>
      <td>83</td>
      <td>Denver</td>
      <td>Den</td>
      <td>Den</td>
      <td>2</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>28</th>
      <td>66</td>
      <td>Anthony Miller</td>
      <td>Chi</td>
      <td>Chi</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>29</th>
      <td>68</td>
      <td>Mason Crosby</td>
      <td>GB</td>
      <td>GB</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>30</th>
      <td>75</td>
      <td>La'Mical Perine</td>
      <td>NYJ</td>
      <td>NYJ</td>
      <td>0</td>
      <td>Dai</td>
      <td></td>
    </tr>
    <tr>
      <th>31</th>
      <td>76</td>
      <td>Anthony McFarland Jr.</td>
      <td>Pit</td>
      <td>Pit</td>
      <td>0</td>
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
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>7</td>
      <td>Tyreek Hill</td>
      <td>WR</td>
      <td>KC</td>
      <td>78</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>33</th>
      <td>11</td>
      <td>Todd Gurley II</td>
      <td>RB</td>
      <td>Atl</td>
      <td>53</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>34</th>
      <td>18</td>
      <td>Mark Ingram II</td>
      <td>RB</td>
      <td>Bal</td>
      <td>52</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>35</th>
      <td>89</td>
      <td>James White</td>
      <td>RB</td>
      <td>NE</td>
      <td>11</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>36</th>
      <td>88</td>
      <td>Deebo Samuel</td>
      <td>WR</td>
      <td>SF</td>
      <td>10</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>37</th>
      <td>179</td>
      <td>Lamar Jackson</td>
      <td>QB</td>
      <td>Bal</td>
      <td>10</td>
      <td>Doug</td>
      <td>D</td>
    </tr>
    <tr>
      <th>38</th>
      <td>98</td>
      <td>Mo Alie-Cox</td>
      <td>Ind</td>
      <td>Ind</td>
      <td>8</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>39</th>
      <td>178</td>
      <td>DeVante Parker</td>
      <td>WR</td>
      <td>Mia</td>
      <td>6</td>
      <td>Doug</td>
      <td>D</td>
    </tr>
    <tr>
      <th>40</th>
      <td>108</td>
      <td>Eric Ebron</td>
      <td>Pit</td>
      <td>Pit</td>
      <td>5</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>41</th>
      <td>86</td>
      <td>Harrison Butker</td>
      <td>K</td>
      <td>KC</td>
      <td>3</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>42</th>
      <td>62</td>
      <td>Adrian Peterson</td>
      <td>RB</td>
      <td>Det</td>
      <td>2</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>43</th>
      <td>117</td>
      <td>Chase Edmonds</td>
      <td>Ari</td>
      <td>Ari</td>
      <td>2</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>44</th>
      <td>121</td>
      <td>Los Angeles</td>
      <td>LAR</td>
      <td>LAR</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>45</th>
      <td>126</td>
      <td>Andy Isabella</td>
      <td>Ari</td>
      <td>Ari</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>46</th>
      <td>135</td>
      <td>Jeff Wilson Jr.</td>
      <td>SF</td>
      <td>SF</td>
      <td>0</td>
      <td>Doug</td>
      <td></td>
    </tr>
    <tr>
      <th>47</th>
      <td>177</td>
      <td>Randall Cobb</td>
      <td>Hou</td>
      <td>Hou</td>
      <td>0</td>
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
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>15</td>
      <td>David Johnson</td>
      <td>RB</td>
      <td>Hou</td>
      <td>59</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>49</th>
      <td>171</td>
      <td>Chris Godwin</td>
      <td>WR</td>
      <td>TB</td>
      <td>45</td>
      <td>Evan</td>
      <td>D</td>
    </tr>
    <tr>
      <th>50</th>
      <td>43</td>
      <td>Marquise Brown</td>
      <td>WR</td>
      <td>Bal</td>
      <td>34</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>51</th>
      <td>10</td>
      <td>Tyler Higbee</td>
      <td>TE</td>
      <td>LAR</td>
      <td>22</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>52</th>
      <td>73</td>
      <td>Antonio Gibson</td>
      <td>RB</td>
      <td>Was</td>
      <td>22</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>53</th>
      <td>170</td>
      <td>Tyler Lockett</td>
      <td>WR</td>
      <td>Sea</td>
      <td>21</td>
      <td>Evan</td>
      <td>BCD</td>
    </tr>
    <tr>
      <th>54</th>
      <td>41</td>
      <td>Julian Edelman</td>
      <td>WR</td>
      <td>NE</td>
      <td>19</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>55</th>
      <td>55</td>
      <td>Josh Allen</td>
      <td>QB</td>
      <td>Buf</td>
      <td>18</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>56</th>
      <td>64</td>
      <td>Tarik Cohen</td>
      <td>RB</td>
      <td>Chi</td>
      <td>17</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>57</th>
      <td>168</td>
      <td>Kyler Murray</td>
      <td>QB</td>
      <td>Ari</td>
      <td>17</td>
      <td>Evan</td>
      <td>D</td>
    </tr>
    <tr>
      <th>58</th>
      <td>72</td>
      <td>Austin Hooper</td>
      <td>TE</td>
      <td>Cle</td>
      <td>13</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>59</th>
      <td>52</td>
      <td>Kerryon Johnson</td>
      <td>RB</td>
      <td>Det</td>
      <td>12</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>60</th>
      <td>51</td>
      <td>San Francisco</td>
      <td>DEF</td>
      <td>SF</td>
      <td>10</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>61</th>
      <td>58</td>
      <td>Sammy Watkins</td>
      <td>KC</td>
      <td>KC</td>
      <td>7</td>
      <td>Evan</td>
      <td></td>
    </tr>
    <tr>
      <th>62</th>
      <td>169</td>
      <td>Ronald Jones II</td>
      <td>RB</td>
      <td>TB</td>
      <td>7</td>
      <td>Evan</td>
      <td>D</td>
    </tr>
    <tr>
      <th>63</th>
      <td>47</td>
      <td>Greg Zuerlein</td>
      <td>K</td>
      <td>Dal</td>
      <td>4</td>
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
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>2</td>
      <td>Clyde Edwards-Helaire</td>
      <td>RB</td>
      <td>KC</td>
      <td>80</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>65</th>
      <td>180</td>
      <td>Ezekiel Elliott</td>
      <td>RB</td>
      <td>Dal</td>
      <td>71</td>
      <td>Jake</td>
      <td>BCD</td>
    </tr>
    <tr>
      <th>66</th>
      <td>16</td>
      <td>Darren Waller</td>
      <td>TE</td>
      <td>LV</td>
      <td>51</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>67</th>
      <td>183</td>
      <td>Michael Thomas</td>
      <td>WR</td>
      <td>NO</td>
      <td>38</td>
      <td>Jake</td>
      <td>ABCD</td>
    </tr>
    <tr>
      <th>68</th>
      <td>181</td>
      <td>JuJu Smith-Schuster</td>
      <td>WR</td>
      <td>Pit</td>
      <td>21</td>
      <td>Jake</td>
      <td>BCD</td>
    </tr>
    <tr>
      <th>69</th>
      <td>182</td>
      <td>Cooper Kupp</td>
      <td>WR</td>
      <td>LAR</td>
      <td>17</td>
      <td>Jake</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>70</th>
      <td>130</td>
      <td>Marquez Valdes-Scantling</td>
      <td>GB</td>
      <td>GB</td>
      <td>13</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>71</th>
      <td>142</td>
      <td>Russell Gage</td>
      <td>Atl</td>
      <td>Atl</td>
      <td>12</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>72</th>
      <td>3</td>
      <td>Tom Brady</td>
      <td>QB</td>
      <td>TB</td>
      <td>11</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>73</th>
      <td>30</td>
      <td>Sony Michel</td>
      <td>RB</td>
      <td>NE</td>
      <td>7</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>74</th>
      <td>112</td>
      <td>Corey Davis</td>
      <td>Ten</td>
      <td>Ten</td>
      <td>6</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>75</th>
      <td>95</td>
      <td>Jonnu Smith</td>
      <td>TE</td>
      <td>Ten</td>
      <td>3</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>76</th>
      <td>102</td>
      <td>Zane Gonzalez</td>
      <td>K</td>
      <td>Ari</td>
      <td>1</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>77</th>
      <td>46</td>
      <td>Jared Goff</td>
      <td>LAR</td>
      <td>LAR</td>
      <td>0</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>78</th>
      <td>81</td>
      <td>Malcolm Brown</td>
      <td>LAR</td>
      <td>LAR</td>
      <td>0</td>
      <td>Jake</td>
      <td></td>
    </tr>
    <tr>
      <th>79</th>
      <td>139</td>
      <td>Arizona</td>
      <td>Ari</td>
      <td>Ari</td>
      <td>0</td>
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
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>166</td>
      <td>Calvin Ridley</td>
      <td>WR</td>
      <td>Atl</td>
      <td>41</td>
      <td>Jiwei</td>
      <td>D</td>
    </tr>
    <tr>
      <th>81</th>
      <td>37</td>
      <td>D'Andre Swift</td>
      <td>RB</td>
      <td>Det</td>
      <td>39</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>82</th>
      <td>165</td>
      <td>Chris Carson</td>
      <td>RB</td>
      <td>Sea</td>
      <td>37</td>
      <td>Jiwei</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>83</th>
      <td>23</td>
      <td>T.Y. Hilton</td>
      <td>WR</td>
      <td>Ind</td>
      <td>36</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>84</th>
      <td>12</td>
      <td>Devonta Freeman</td>
      <td>NYG</td>
      <td>NYG</td>
      <td>27</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>85</th>
      <td>164</td>
      <td>Kenyan Drake</td>
      <td>RB</td>
      <td>Ari</td>
      <td>25</td>
      <td>Jiwei</td>
      <td>D</td>
    </tr>
    <tr>
      <th>86</th>
      <td>33</td>
      <td>A.J. Green</td>
      <td>WR</td>
      <td>Cin</td>
      <td>22</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>87</th>
      <td>49</td>
      <td>Hayden Hurst</td>
      <td>TE</td>
      <td>Atl</td>
      <td>20</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>88</th>
      <td>77</td>
      <td>Tee Higgins</td>
      <td>Cin</td>
      <td>Cin</td>
      <td>12</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>89</th>
      <td>167</td>
      <td>Dak Prescott</td>
      <td>QB</td>
      <td>Dal</td>
      <td>10</td>
      <td>Jiwei</td>
      <td>D</td>
    </tr>
    <tr>
      <th>90</th>
      <td>61</td>
      <td>Justin Tucker</td>
      <td>K</td>
      <td>Bal</td>
      <td>5</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>91</th>
      <td>94</td>
      <td>Justin Jefferson</td>
      <td>WR</td>
      <td>Min</td>
      <td>4</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>92</th>
      <td>96</td>
      <td>Mike Gesicki</td>
      <td>TE</td>
      <td>Mia</td>
      <td>4</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>93</th>
      <td>80</td>
      <td>Baltimore</td>
      <td>DEF</td>
      <td>Bal</td>
      <td>3</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>94</th>
      <td>104</td>
      <td>Allen Lazard</td>
      <td>WR</td>
      <td>GB</td>
      <td>1</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
    <tr>
      <th>95</th>
      <td>140</td>
      <td>Boston Scott</td>
      <td>RB</td>
      <td>Phi</td>
      <td>1</td>
      <td>Jiwei</td>
      <td></td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Joel']
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>1</td>
      <td>DeAndre Hopkins</td>
      <td>WR</td>
      <td>Ari</td>
      <td>75</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>97</th>
      <td>19</td>
      <td>Mike Evans</td>
      <td>WR</td>
      <td>TB</td>
      <td>67</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>98</th>
      <td>152</td>
      <td>David Montgomery</td>
      <td>RB</td>
      <td>Chi</td>
      <td>47</td>
      <td>Joel</td>
      <td>D</td>
    </tr>
    <tr>
      <th>99</th>
      <td>45</td>
      <td>Matt Ryan</td>
      <td>QB</td>
      <td>Atl</td>
      <td>26</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>100</th>
      <td>57</td>
      <td>Will Fuller V</td>
      <td>WR</td>
      <td>Hou</td>
      <td>22</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>101</th>
      <td>21</td>
      <td>Jared Cook</td>
      <td>TE</td>
      <td>NO</td>
      <td>17</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>102</th>
      <td>153</td>
      <td>James Conner</td>
      <td>RB</td>
      <td>Pit</td>
      <td>17</td>
      <td>Joel</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>103</th>
      <td>154</td>
      <td>Devin Singletary</td>
      <td>RB</td>
      <td>Buf</td>
      <td>13</td>
      <td>Joel</td>
      <td>D</td>
    </tr>
    <tr>
      <th>104</th>
      <td>129</td>
      <td>Darrell Henderson Jr.</td>
      <td>LAR</td>
      <td>LAR</td>
      <td>11</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>105</th>
      <td>48</td>
      <td>T.J. Hockenson</td>
      <td>TE</td>
      <td>Det</td>
      <td>5</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>106</th>
      <td>155</td>
      <td>Jamison Crowder</td>
      <td>WR</td>
      <td>NYJ</td>
      <td>5</td>
      <td>Joel</td>
      <td>D</td>
    </tr>
    <tr>
      <th>107</th>
      <td>69</td>
      <td>Matt Prater</td>
      <td>K</td>
      <td>Det</td>
      <td>1</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>108</th>
      <td>101</td>
      <td>Pittsburgh</td>
      <td>DEF</td>
      <td>Pit</td>
      <td>1</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>109</th>
      <td>111</td>
      <td>Golden Tate</td>
      <td>WR</td>
      <td>NYG</td>
      <td>1</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>110</th>
      <td>91</td>
      <td>Greg Ward</td>
      <td>Phi</td>
      <td>Phi</td>
      <td>0</td>
      <td>Joel</td>
      <td></td>
    </tr>
    <tr>
      <th>111</th>
      <td>120</td>
      <td>Nyheim Hines</td>
      <td>Ind</td>
      <td>Ind</td>
      <td>0</td>
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
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>113</td>
      <td>Saquon Barkley</td>
      <td>NYG</td>
      <td>NYG</td>
      <td>72</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>113</th>
      <td>13</td>
      <td>Jonathan Taylor</td>
      <td>RB</td>
      <td>Ind</td>
      <td>59</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>114</th>
      <td>158</td>
      <td>Adam Thielen</td>
      <td>WR</td>
      <td>Min</td>
      <td>42</td>
      <td>Matt</td>
      <td>BCD</td>
    </tr>
    <tr>
      <th>115</th>
      <td>159</td>
      <td>Allen Robinson II</td>
      <td>WR</td>
      <td>Chi</td>
      <td>34</td>
      <td>Matt</td>
      <td>D</td>
    </tr>
    <tr>
      <th>116</th>
      <td>5</td>
      <td>Cam Akers</td>
      <td>RB</td>
      <td>LAR</td>
      <td>33</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>117</th>
      <td>38</td>
      <td>Russell Wilson</td>
      <td>QB</td>
      <td>Sea</td>
      <td>33</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>118</th>
      <td>44</td>
      <td>Jarvis Landry</td>
      <td>WR</td>
      <td>Cle</td>
      <td>32</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>119</th>
      <td>54</td>
      <td>Emmanuel Sanders</td>
      <td>WR</td>
      <td>NO</td>
      <td>18</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>120</th>
      <td>157</td>
      <td>Aaron Jones</td>
      <td>RB</td>
      <td>GB</td>
      <td>16</td>
      <td>Matt</td>
      <td>BCD</td>
    </tr>
    <tr>
      <th>121</th>
      <td>156</td>
      <td>Mark Andrews</td>
      <td>TE</td>
      <td>Bal</td>
      <td>12</td>
      <td>Matt</td>
      <td>D</td>
    </tr>
    <tr>
      <th>122</th>
      <td>67</td>
      <td>Aaron Rodgers</td>
      <td>QB</td>
      <td>GB</td>
      <td>10</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>123</th>
      <td>20</td>
      <td>Carlos Hyde</td>
      <td>RB</td>
      <td>Sea</td>
      <td>4</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>124</th>
      <td>106</td>
      <td>New England</td>
      <td>DEF</td>
      <td>NE</td>
      <td>3</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>125</th>
      <td>131</td>
      <td>N'Keal Harry</td>
      <td>WR</td>
      <td>NE</td>
      <td>1</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>126</th>
      <td>103</td>
      <td>Jacksonville</td>
      <td>Jax</td>
      <td>Jax</td>
      <td>0</td>
      <td>Matt</td>
      <td></td>
    </tr>
    <tr>
      <th>127</th>
      <td>122</td>
      <td>Rodrigo Blankenship</td>
      <td>Ind</td>
      <td>Ind</td>
      <td>0</td>
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
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>25</td>
      <td>Amari Cooper</td>
      <td>WR</td>
      <td>Dal</td>
      <td>56</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>129</th>
      <td>192</td>
      <td>Derrick Henry</td>
      <td>RB</td>
      <td>Ten</td>
      <td>49</td>
      <td>Rajiv</td>
      <td>D</td>
    </tr>
    <tr>
      <th>130</th>
      <td>8</td>
      <td>Melvin Gordon III</td>
      <td>RB</td>
      <td>Den</td>
      <td>47</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>131</th>
      <td>26</td>
      <td>Terry McLaurin</td>
      <td>WR</td>
      <td>Was</td>
      <td>44</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>132</th>
      <td>28</td>
      <td>Evan Engram</td>
      <td>TE</td>
      <td>NYG</td>
      <td>35</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>133</th>
      <td>32</td>
      <td>Michael Gallup</td>
      <td>WR</td>
      <td>Dal</td>
      <td>28</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>134</th>
      <td>42</td>
      <td>Drew Brees</td>
      <td>QB</td>
      <td>NO</td>
      <td>23</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>135</th>
      <td>24</td>
      <td>Phillip Lindsay</td>
      <td>RB</td>
      <td>Den</td>
      <td>21</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>136</th>
      <td>90</td>
      <td>Darius Slayton</td>
      <td>WR</td>
      <td>NYG</td>
      <td>10</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>137</th>
      <td>124</td>
      <td>Robbie Gould</td>
      <td>K</td>
      <td>SF</td>
      <td>1</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>138</th>
      <td>132</td>
      <td>Hunter Renfrow</td>
      <td>WR</td>
      <td>LV</td>
      <td>1</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>139</th>
      <td>143</td>
      <td>Alexander Mattison</td>
      <td>RB</td>
      <td>Min</td>
      <td>1</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>140</th>
      <td>145</td>
      <td>Justin Jackson</td>
      <td>RB</td>
      <td>LAC</td>
      <td>1</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>141</th>
      <td>146</td>
      <td>Jerick McKinnon</td>
      <td>RB</td>
      <td>SF</td>
      <td>1</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>142</th>
      <td>137</td>
      <td>Kansas City</td>
      <td>KC</td>
      <td>KC</td>
      <td>0</td>
      <td>Rajiv</td>
      <td></td>
    </tr>
    <tr>
      <th>143</th>
      <td>147</td>
      <td>Jimmy Graham</td>
      <td>Chi</td>
      <td>Chi</td>
      <td>0</td>
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
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>148</td>
      <td>Dalvin Cook</td>
      <td>RB</td>
      <td>Min</td>
      <td>79</td>
      <td>Ron</td>
      <td>D</td>
    </tr>
    <tr>
      <th>145</th>
      <td>14</td>
      <td>Le'Veon Bell</td>
      <td>RB</td>
      <td>NYJ</td>
      <td>48</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>146</th>
      <td>17</td>
      <td>Stefon Diggs</td>
      <td>WR</td>
      <td>Buf</td>
      <td>41</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>147</th>
      <td>40</td>
      <td>Tyler Boyd</td>
      <td>WR</td>
      <td>Cin</td>
      <td>30</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>148</th>
      <td>149</td>
      <td>Austin Ekeler</td>
      <td>RB</td>
      <td>LAC</td>
      <td>15</td>
      <td>Ron</td>
      <td>D</td>
    </tr>
    <tr>
      <th>149</th>
      <td>176</td>
      <td>DJ Chark Jr.</td>
      <td>WR</td>
      <td>Jax</td>
      <td>14</td>
      <td>Ron</td>
      <td>D</td>
    </tr>
    <tr>
      <th>150</th>
      <td>151</td>
      <td>Courtland Sutton</td>
      <td>WR</td>
      <td>Den</td>
      <td>10</td>
      <td>Ron</td>
      <td>D</td>
    </tr>
    <tr>
      <th>151</th>
      <td>36</td>
      <td>Matthew Stafford</td>
      <td>QB</td>
      <td>Det</td>
      <td>6</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>152</th>
      <td>123</td>
      <td>Myles Gaskin</td>
      <td>Mia</td>
      <td>Mia</td>
      <td>6</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>153</th>
      <td>150</td>
      <td>DK Metcalf</td>
      <td>WR</td>
      <td>Sea</td>
      <td>5</td>
      <td>Ron</td>
      <td>D</td>
    </tr>
    <tr>
      <th>154</th>
      <td>63</td>
      <td>Wil Lutz</td>
      <td>K</td>
      <td>NO</td>
      <td>3</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>155</th>
      <td>85</td>
      <td>Indianapolis</td>
      <td>Ind</td>
      <td>Ind</td>
      <td>1</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>156</th>
      <td>50</td>
      <td>Laviska Shenault Jr.</td>
      <td>Jax</td>
      <td>Jax</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>157</th>
      <td>74</td>
      <td>Dallas Goedert</td>
      <td>Phi</td>
      <td>Phi</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>158</th>
      <td>105</td>
      <td>Scotty Miller</td>
      <td>TB</td>
      <td>TB</td>
      <td>0</td>
      <td>Ron</td>
      <td></td>
    </tr>
    <tr>
      <th>159</th>
      <td>114</td>
      <td>Logan Thomas</td>
      <td>Was</td>
      <td>Was</td>
      <td>0</td>
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
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>4</td>
      <td>Julio Jones</td>
      <td>WR</td>
      <td>Atl</td>
      <td>78</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>161</th>
      <td>189</td>
      <td>Travis Kelce</td>
      <td>TE</td>
      <td>KC</td>
      <td>64</td>
      <td>Ryan</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>162</th>
      <td>188</td>
      <td>Kenny Golladay</td>
      <td>WR</td>
      <td>Det</td>
      <td>46</td>
      <td>Ryan</td>
      <td>D</td>
    </tr>
    <tr>
      <th>163</th>
      <td>39</td>
      <td>Deshaun Watson</td>
      <td>QB</td>
      <td>Hou</td>
      <td>44</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>164</th>
      <td>191</td>
      <td>Nick Chubb</td>
      <td>RB</td>
      <td>Cle</td>
      <td>15</td>
      <td>Ryan</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>165</th>
      <td>93</td>
      <td>Gardner Minshew II</td>
      <td>Jax</td>
      <td>Jax</td>
      <td>9</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>166</th>
      <td>53</td>
      <td>Dion Lewis</td>
      <td>NYG</td>
      <td>NYG</td>
      <td>7</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>167</th>
      <td>190</td>
      <td>Kareem Hunt</td>
      <td>RB</td>
      <td>Cle</td>
      <td>6</td>
      <td>Ryan</td>
      <td>D</td>
    </tr>
    <tr>
      <th>168</th>
      <td>71</td>
      <td>Brandon Aiyuk</td>
      <td>WR</td>
      <td>SF</td>
      <td>4</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>169</th>
      <td>118</td>
      <td>Michael Pittman Jr.</td>
      <td>WR</td>
      <td>Ind</td>
      <td>2</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>170</th>
      <td>97</td>
      <td>Noah Fant</td>
      <td>TE</td>
      <td>Den</td>
      <td>1</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>171</th>
      <td>107</td>
      <td>Jalen Reagor</td>
      <td>WR</td>
      <td>Phi</td>
      <td>1</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>172</th>
      <td>116</td>
      <td>New Orleans</td>
      <td>DEF</td>
      <td>NO</td>
      <td>1</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>173</th>
      <td>125</td>
      <td>Jason Myers</td>
      <td>Sea</td>
      <td>Sea</td>
      <td>1</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>174</th>
      <td>133</td>
      <td>Tony Pollard</td>
      <td>RB</td>
      <td>Dal</td>
      <td>1</td>
      <td>Ryan</td>
      <td></td>
    </tr>
    <tr>
      <th>175</th>
      <td>92</td>
      <td>Chase Claypool</td>
      <td>Pit</td>
      <td>Pit</td>
      <td>0</td>
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
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>160</td>
      <td>Christian McCaffrey</td>
      <td>RB</td>
      <td>Car</td>
      <td>99</td>
      <td>Sean</td>
      <td>D</td>
    </tr>
    <tr>
      <th>177</th>
      <td>31</td>
      <td>Robert Woods</td>
      <td>WR</td>
      <td>LAR</td>
      <td>57</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>178</th>
      <td>138</td>
      <td>Mike Davis</td>
      <td>Car</td>
      <td>Car</td>
      <td>33</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>179</th>
      <td>162</td>
      <td>Alvin Kamara</td>
      <td>RB</td>
      <td>NO</td>
      <td>25</td>
      <td>Sean</td>
      <td>BCD</td>
    </tr>
    <tr>
      <th>180</th>
      <td>161</td>
      <td>George Kittle</td>
      <td>TE</td>
      <td>SF</td>
      <td>18</td>
      <td>Sean</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>181</th>
      <td>60</td>
      <td>Diontae Johnson</td>
      <td>WR</td>
      <td>Pit</td>
      <td>17</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>182</th>
      <td>163</td>
      <td>A.J. Brown</td>
      <td>WR</td>
      <td>Ten</td>
      <td>11</td>
      <td>Sean</td>
      <td>D</td>
    </tr>
    <tr>
      <th>183</th>
      <td>78</td>
      <td>Mecole Hardman</td>
      <td>KC</td>
      <td>KC</td>
      <td>4</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>184</th>
      <td>109</td>
      <td>Dalton Schultz</td>
      <td>Dal</td>
      <td>Dal</td>
      <td>3</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>185</th>
      <td>136</td>
      <td>Parris Campbell</td>
      <td>WR</td>
      <td>Ind</td>
      <td>1</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>186</th>
      <td>144</td>
      <td>Seattle</td>
      <td>Sea</td>
      <td>Sea</td>
      <td>1</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>187</th>
      <td>70</td>
      <td>Damien Harris</td>
      <td>NE</td>
      <td>NE</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>188</th>
      <td>99</td>
      <td>James Robinson</td>
      <td>Jax</td>
      <td>Jax</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>189</th>
      <td>127</td>
      <td>Preston Williams</td>
      <td>Mia</td>
      <td>Mia</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>190</th>
      <td>134</td>
      <td>Cam Newton</td>
      <td>NE</td>
      <td>NE</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
    <tr>
      <th>191</th>
      <td>141</td>
      <td>Joey Slye</td>
      <td>Car</td>
      <td>Car</td>
      <td>0</td>
      <td>Sean</td>
      <td></td>
    </tr>
  </tbody>
</table>
</div>




```python
draft_df[draft_df['manager'] == 'Chi Shing']
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
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
      <td>6</td>
      <td>Josh Jacobs</td>
      <td>RB</td>
      <td>LV</td>
      <td>68</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>1</th>
      <td>185</td>
      <td>Joe Mixon</td>
      <td>RB</td>
      <td>Cin</td>
      <td>63</td>
      <td>Chi Shing</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>2</th>
      <td>9</td>
      <td>Odell Beckham Jr.</td>
      <td>WR</td>
      <td>Cle</td>
      <td>53</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>3</th>
      <td>22</td>
      <td>Leonard Fournette</td>
      <td>RB</td>
      <td>TB</td>
      <td>33</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>4</th>
      <td>184</td>
      <td>Hunter Henry</td>
      <td>TE</td>
      <td>LAC</td>
      <td>21</td>
      <td>Chi Shing</td>
      <td>D</td>
    </tr>
    <tr>
      <th>5</th>
      <td>56</td>
      <td>Marvin Jones Jr.</td>
      <td>WR</td>
      <td>Det</td>
      <td>18</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>6</th>
      <td>65</td>
      <td>CeeDee Lamb</td>
      <td>WR</td>
      <td>Dal</td>
      <td>18</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>7</th>
      <td>187</td>
      <td>Patrick Mahomes</td>
      <td>QB</td>
      <td>KC</td>
      <td>15</td>
      <td>Chi Shing</td>
      <td>CD</td>
    </tr>
    <tr>
      <th>8</th>
      <td>87</td>
      <td>Christian Kirk</td>
      <td>WR</td>
      <td>Ari</td>
      <td>11</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>9</th>
      <td>186</td>
      <td>John Brown</td>
      <td>WR</td>
      <td>Buf</td>
      <td>8</td>
      <td>Chi Shing</td>
      <td>D</td>
    </tr>
    <tr>
      <th>10</th>
      <td>115</td>
      <td>Tevin Coleman</td>
      <td>RB</td>
      <td>SF</td>
      <td>2</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>11</th>
      <td>79</td>
      <td>Cole Beasley</td>
      <td>WR</td>
      <td>Buf</td>
      <td>1</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>12</th>
      <td>110</td>
      <td>Tampa Bay</td>
      <td>DEF</td>
      <td>TB</td>
      <td>1</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>13</th>
      <td>128</td>
      <td>Robby Anderson</td>
      <td>WR</td>
      <td>Car</td>
      <td>1</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>14</th>
      <td>100</td>
      <td>Michael Badgley</td>
      <td>LAC</td>
      <td>LAC</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
    <tr>
      <th>15</th>
      <td>119</td>
      <td>Benny Snell Jr.</td>
      <td>Pit</td>
      <td>Pit</td>
      <td>0</td>
      <td>Chi Shing</td>
      <td></td>
    </tr>
  </tbody>
</table>
</div>


