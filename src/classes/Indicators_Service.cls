public class Indicators_Service {
    public static List<Indicator> getIndicatorsForObject(SObject sob) {
        List<Indicator> result = new List<Indicator>();
        for(Indicator__mdt config : [SELECT DeveloperName, Grid_Order__c,
                                     Field_API_Name__c, Enabled_Color__c,
                                     Contains_Value__c, Display_Value__c,
                                     Disabled_Color__c, Type__c, Hover_Text__c
                                     FROM Indicator__mdt
                                     WHERE Entity__c = :sob.getSObjectType().getDescribe().getName()
                                     ORDER BY Grid_Order__c]) {
                                         result.add(evaluateIndicator(config,sob));
                                     }
        return result;
    }

    public static List<String> getFieldNamesForObject(SObjectType t) {
        Set<String> result = new Set<String>();
        for(Indicator__mdt config : [SELECT DeveloperName,  Field_API_Name__c FROM Indicator__mdt WHERE Field_API_Name__c != null AND Entity__c = :t.getDescribe().getName() ]) {
            result.add(config.Field_API_Name__c);
        }
        return new List<String>(result);
    }

    private static Indicator evaluateIndicator(Indicator__mdt config, SObject sob) {
        Object field = '';
        if(String.isNotBlank(config.Field_API_Name__c)) {
            field = sob.get(config.Field_API_Name__c);

        }
        Boolean enabled = false;
        Boolean display = true;
        if(config.Type__c == 'Contains') {
            if(String.isNotBlank((String)field) && String.isNotBlank(config.Contains_Value__c)) {
                enabled = ((String)field).contains(config.Contains_Value__c);
            }

        } else if(config.Type__c == 'Boolean') {
            enabled = (Boolean)field;
        } else if(config.Type__c == 'Is Not Null') {
            if(String.isNotBlank((String)field))
        		enabled = true;
        } else if(config.Type__c == 'Greater Than') {
            if(field != null && String.isNotBlank(config.Contains_Value__c)) {
                enabled = (Decimal.valueOf((String)field) > Decimal.valueOf(config.Contains_Value__c));
            }
        } else if(config.Type__c == 'Less Than') {
            if(field != null && String.isNotBlank(config.Contains_Value__c)) {
                enabled = (Decimal.valueOf((String)field) < Decimal.valueOf(config.Contains_Value__c));
            }
        } else if(config.Type__c == 'Blank') {
            enabled = false;
            display = false;
        }
        return new Indicator(config.Display_Value__c, enabled ? config.Enabled_Color__c : config.Disabled_Color__c, display, config.Hover_Text__c);
    }

    public class Indicator {
        public string Color {get;set;}
        public string Value {get;set;}
        public Boolean Display {get;set;}
        public string Hover {get;set;}

        public Indicator(String value, String color, Boolean display, String hover) {
            this.Value = value; this.Color = color; this.Display = display; this.Hover = hover;
        }
    }
}