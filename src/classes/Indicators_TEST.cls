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
        System.assertEquals(result.size(),1);
    }
    
}