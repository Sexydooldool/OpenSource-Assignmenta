import pandas as pd
import sklearn 
from sklearn.pipeline import make_pipeline
from sklearn.ensemble import RandomForestRegressor
from sklearn.tree import DecisionTreeRegressor
from sklearn.svm import SVR
from sklearn.preprocessing import StandardScaler
import numpy as np




dataset_df = pd.read_csv('2019_kbo_for_kaggle_v2.csv')

def sort_dataset(dataset_df):

	return dataset_df.sort_values('year',ascending = True)


def split_dataset(dataset_df):

    inputdata = dataset_df[['age', 'G', 'PA', 'AB', 'R', 'H', '2B', '3B', 'HR', 'RBI',
                             'SB', 'CS', 'BB', 'HBP', 'SO', 'GDP', 'fly', 'war']].copy()
    outputdata = dataset_df['salary'].mul(0.001).copy()

    X_train, X_test = inputdata.iloc[:1718], inputdata.iloc[1718:]
    Y_train, Y_test = outputdata.iloc[:1718], outputdata.iloc[1718:]

    return X_train, X_test, Y_train, Y_test 

	
def extract_numerical_cols(dataset_df):

    inputdata = dataset_df[['age', 'G', 'PA', 'AB', 'R', 'H', '2B', '3B', 'HR', 'RBI',
                             'SB', 'CS', 'BB', 'HBP', 'SO', 'GDP', 'fly', 'war']].copy()
    return inputdata
	

def train_predict_decision_tree(X_train, Y_train, X_test):
	
    clf = DecisionTreeRegressor()
    clf.fit(X_train, Y_train)
    predictions = clf.predict(X_test)

    return predictions

def train_predict_random_forest(X_train, Y_train, X_test):
    
    clf = RandomForestRegressor()
    clf.fit(X_train, Y_train)
    predictions = clf.predict(X_test)

    return predictions


def train_predict_svm(X_train, Y_train, X_test):

    pipe = make_pipeline(
    StandardScaler(),
    SVR()
	)
    pipe.fit(X_train,Y_train)
    predictions = pipe.predict(X_test)

    return predictions



def calculate_RMSE(labels, predictions):
      
    RMSE = np.sqrt(np.mean((predictions-labels)**2))
    return RMSE


if __name__=='__main__':
	#DO NOT MODIFY THIS FUNCTION UNLESS PATH TO THE CSV MUST BE CHANGED.
	data_df = pd.read_csv('2019_kbo_for_kaggle_v2.csv')
	
	sorted_df = sort_dataset(data_df)	
	X_train, X_test, Y_train, Y_test = split_dataset(sorted_df)
	
	X_train = extract_numerical_cols(X_train)
	X_test = extract_numerical_cols(X_test)

	dt_predictions = train_predict_decision_tree(X_train, Y_train, X_test)
	rf_predictions = train_predict_random_forest(X_train, Y_train, X_test)
	svm_predictions = train_predict_svm(X_train, Y_train, X_test)
	
	print ("Decision Tree Test RMSE: ", calculate_RMSE(Y_test, dt_predictions))	
	print ("Random Forest Test RMSE: ", calculate_RMSE(Y_test, rf_predictions))	
	print ("SVM Test RMSE: ", calculate_RMSE(Y_test, svm_predictions))