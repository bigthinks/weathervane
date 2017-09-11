@isTest public class Indicators_TEST {
    /* THESE ARE COVERAGE TESTS THEY ARE NOT GOOD TESTS = I DON'T FEEL GOOD ABT THESE YO */
    @isTest public static void test_IndicatorsCTRLCoverage() {
        Contact c = new Contact();
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        Indicators_CTRL ext = new Indicators_CTRL(sc);
        List<Indicators_Service.Indicator> result = ext.indicators;
        System.assertEquals(result,null);
    }
    @isTest public static void test_IndicatorsServiceCoverage() {
        Contact c = new Contact();
        List<Indicators_Service.Indicator> result = Indicators_Service.getIndicatorsForObject(c);
        Integer indCount = [SELECT Count() FROM Indicator__mdt WHERE Entity__c = 'Contact' ];
        System.assertEquals(result.size(),indCount);
    }

    public static final String testSVG =
        '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" display="none"><symbol id="account"></symbol><symbol viewBox="0 0 24 24" id="announcement"></symbol><symbol viewBox="0 0 24 24" id="answer_best"></symbol>';
    
}