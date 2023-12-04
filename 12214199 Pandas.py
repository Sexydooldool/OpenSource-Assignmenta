import pandas as pd


#년도별 상위 10개 출력 
data = pd.read_csv('2019_kbo_for_kaggle_v2.csv')
mylist = ['H', 'avg', 'HR', 'OBP']

for i in range(2015, 2019):
    print(f'best in {i}')
    subset_data = data[data['year'] == i].copy()  
    
    for element in mylist:
        subset_data = subset_data.sort_values(element, ascending=False)
        subset_data.reset_index(drop=True, inplace=True)  
        subset = subset_data.iloc[0:10]
        print(subset[['batter_name',element]])


#포지션 별 최대 war값 가진 행 찾기

myposition = ['포수', '1루수', '2루수', '3루수', '유격수', '좌익수', '중견수', '우익수']

for element in myposition:
    data = pd.read_csv('2019_kbo_for_kaggle_v2.csv').copy()
    print('포지션:', element,'최고 war값 플레이어 출력')
    
    subset_data = data[(data['year'] == 2018) & (data['cp'] == element)]
    subset_data = subset_data.sort_values('war', ascending=False)
    
    if not subset_data.empty:
        top_player = subset_data.iloc[0]
        print(top_player)
    else:
        print('데이터 없음')
    print('---')



# 최대의 상관계수를 가지는 기준값 찾기

mylist = ['R', 'H', 'HR', 'RBI', 'SB', 'war', 'avg', 'OBP', 'SLG']
max_correlations = []

for element in mylist:
    new_data = data[[element, 'salary']].copy()
    corr = new_data.corr()
    
    max_corr_value = abs(corr['salary'][element])
    max_correlations.append(max_corr_value)

max_corr_variable = mylist[max_correlations.index(max(max_correlations))]

print(f"최고 상관계수를 가진 변수는 {max_corr_variable}이며, 상관계수는 {max(max_correlations)}입니다.")


