import MySQLdb as mdb


def fetch(cols,table,where=None,group_by=None,order_by=None,Desc=False,limit=None):
    """
    Purpose: Makes the MySQL quesries more efficitent and faster.
    
    Note: All inputs have to be in STRING format except the 'limit' which is an int
    """
    
    # Opening a Connection to donorsChoose Database
    con = mdb.connect('localhost', 'idx', 'donorsChoose', 'donors');
    cur = con.cursor()
    
    # Creating a query
    query = 'SELECT ' + cols + ' FROM ' + table + ' '
    if where: query += ' WHERE ' + where + ' '
    if group_by: query += 'GROUP BY ' + group_by + ' '
    if order_by: query += 'ORDER BY ' + order_by + ' '
    if Desc: query += 'DESC '
    if limit: query += 'LIMIT ' + str(limit)
    
    # fetching the data and turn it into a pandas dataframe
    cur.execute(query)
    output = np.array(cur.fetchall())
    colm = [f[0] for f in cur.description]
    output = pd.DataFrame(output)
    output.columns = colm

    # Closing the connection to the database
    con.close()
    
    return output




def chi2_test(colName):
    '''
    Purpose: Performs Chi2 independet test on a categorical variable column
    and return the associated p-value.
    
    Note: This function is specifically designed for LA projects and the 
    independent test perfomed based on the funding status (funded or not)
    '''
    
    # Create a multiIndex_table table based on the variable and funding status
    multiIndex_table = projects_la.groupby([colName,'funding_status'])['funding_status'].count()
               
    # Turning funding status into two columns (completed/expired)
    unstacked = multiIndex_table.unstack('funding_status')

    # Making sure that there are at least 10 observation per case
    unstacked = unstacked[unstacked.completed >= 10]
    unstacked = unstacked[unstacked.expired >= 10]
    
    Chi2, p_value, dof, expected = scipy.stats.chi2_contingency(unstacked)
    
    return p_value




def bootstrap_median(colName,nofSimulation=1000,nofSample=1000,plot_hist=False):
    """
    Purpose: Performs two groups independent tests and compares their median
    
    Note: This function is specifically designed for LA projects and the 
    independent test perfomed based on the funding status (funded or not)
    """
    
    median_diff = []
    
    Funded    = projects_la[projects_la.funding_status=='completed']
    notFunded = projects_la[projects_la.funding_status=='expired']

    # Bootstraping: finding the median differences and severl (nofSimulation) resample of
    # funded and not funded projects. 
    for i in xrange(nofSimulation):
        median1 = Funded[colName].iloc[np.random.randint(0, len(Funded[colName]), size=nofSample)].median()
        median2 = notFunded[colName].iloc[np.random.randint(0, len(notFunded[colName]), size=nofSample)].median()
        median_diff.append(median1 - median2)

    # The number of simulations and resample size will be more than
    # couple of thousands --> use normal z test (CLT)
    mean = np.mean(median_diff)
    SD = np.std(median_diff)
    z = mean/SD
    z = min(-z,z)  # Two sided test --> use the lower quantile
    pValue = 2*stats.norm.cdf(z)
    percLow, percHigh = np.percentile(median_diff,[2.5,97.5])


    print 'The mean of median difference of {0} is {1}, the confidence interval=({2},{3}), and  p-value={4}.'.\
            format(colName,round(mean,2),round(percLow,2),round(percHigh,2),round(pValue,2))
    print
    
    if plot_hist:
        plt.hist(median_diff)   # Optional 




def sampleProportions_chanceOF_success(colName):
    """
    Purpose: Determine wether or not a binary variable contributes to the success probability
    
    Example: Is being a charter school on not correlated to the chance of getting funded.
    
    Note: This function is specifically designed for LA projects and the 
    independent test perfomed based on the funding status (funded or not)
    """
    
    # prevalence of the binary varible: what is the prevalence of the charter school?
    prevalence = float(sum(projects_la[colName] == '1'))

    # Conditional Probability: If it's a charter school, what is the chance of getting funded?
    success = sum(projects_la[projects_la[colName] == '1']['funding_status'] == 'completed')
    
    # Overal success rate: independent of wether or not it's a charter school
    overal_success = sum(projects_la.funding_status == 'completed')/float(projects_la.shape[0])
    
    # funded given it's a charter school
    p = success/prevalence
    sigma = np.sqrt(p*(1-p)/prevalence)
    percLow = p - 1.96*sigma
    percHigh = p + 1.96*sigma
    
    # Confident interval of success rate compare to the overal success
    return (percLow - overal_success, percHigh - overal_success)




def plot_proportions(colName,figSize = (14,19)):
    """
    Purpose: Plots stacked barplots for categorical variable
    
    Note: This function is specifically designed for LA projects and the 
    independent test perfomed based on the funding status (funded or not)
    """
    
    # Create a multiIndex_table table based on the variable and funding status
    multiIndex_table = projects_la.groupby([colName,'funding_status'])['funding_status'].count()
    
    # Turning one of the indices into a column
    multiIndex_table = multiIndex_table.unstack('funding_status')
    
    # Normalizing each row
    multiIndex_table = multiIndex_table.div(multiIndex_table.sum(axis=1), axis=0)
    
    # Making it more readable
    font = {'weight' : 'bold', 'size': 13}
    matplotlib.rc('font', **font)

    ax = multiIndex_table.sort('completed').plot(kind='barh',stacked=True,figsize=figSize)
    ax.set_title('Percentage Funded vs. ' + colName)


if __name__ == "__main__":
    plot_proportions(colName,figSize = (14,19))
    fetch(cols,table,where=None,group_by=None,order_by=None,Desc=False,limit=None)

