global class Indicators_CTRL {
    private SObject sob;
    global List<Indicators_Service.Indicator> indicators {get {
        if(this.sob != null) {
            return Indicators_Service.getIndicatorsForObject(sob);
        } else {
            return null;
        }
    }}
    global Indicators_CTRL(ApexPages.StandardController sc) {
        Id i = sc.getId();
        SObjectType t = sc.getRecord().getsObjectType();
        List<String> fieldNames = Indicators_Service.getFieldNamesForObject(t);
        if(fieldNames.size() > 0){
            String query = 'SELECT Id,'+ String.join(fieldNames,',')+' FROM '+t.getDescribe().getName()+' WHERE Id =:i';
            List<SObject> res = Database.query(query);
            if(res.size()==1) {
                this.sob = res[0];
            }
        }
    }
}