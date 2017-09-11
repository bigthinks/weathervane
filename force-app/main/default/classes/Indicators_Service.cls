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
		String iType = '';
		if(config.Type__c == 'Contains') {
			if(String.isNotBlank((String)field) && String.isNotBlank(config.Contains_Value__c)) {
				enabled = ((String)field).contains(config.Contains_Value__c);
			}

		} else if(config.Type__c == 'Boolean') {
			enabled = (Boolean)field;
		} else if(config.Type__c == 'Is Not Null') {
			if(String.isNotBlank(String.valueOf(field)))   //String.isNotBlank((String)field)
				enabled = true;
		} else if(config.Type__c == 'Greater Than') {
			if(field != null && String.isNotBlank(config.Contains_Value__c)) {
				enabled = (Decimal.valueOf(String.valueOf(field)) > Decimal.valueOf(config.Contains_Value__c));
			}
		} else if(config.Type__c == 'Less Than') {
			if(field != null && String.isNotBlank(config.Contains_Value__c)) {
				enabled = (Decimal.valueOf(String.valueOf(field)) < Decimal.valueOf(config.Contains_Value__c));
			}
		} else if(config.Type__c == 'Blank') {
			enabled = false;
			display = false;
		}

		// include null option as TEXT type and first to avoid null pointer exceptions and accomodate Blank indicator  
		if (config.Display_Value__c == null || (config.Display_Value__c.length() <= 4 && !spriteSet.contains(config.Display_Value__c))) {
			iType = 'TEXT';
		} else if (Pattern.matches('custom[0-9]{1,3}',config.Display_Value__c) && Integer.valueOf(config.Display_Value__c.substring(6)) <= 113) {
			iType = 'CUSTOM_SPRITE';
		} else if (spriteSet.contains(config.Display_Value__c)) {
			iType = 'STANDARD_SPRITE'; 
		} else {
			iType = 'TEXT';
			throw new WeathervaneException('No valid icon found for Display Value ' + config.Display_Value__c + '. Check Indicator record ' + config.DeveloperName);
		}
		
		return new Indicator(config.Display_Value__c, enabled ? config.Enabled_Color__c : config.Disabled_Color__c, display, config.Hover_Text__c, iType);
	}

	public static final Set<String> spriteSet = new Set<String> 
		{'carousel','case','case_change_status','case_comment','case_email','case_log_a_call','case_transcript','client',
		'coaching','connected_apps','contact','contract','custom','custom_notification','dashboard','datadotcom','default',
		'document','drafts','email','email_chatter','empty','endorsement','environment_hub','event','feed','feedback',
		'file','flow','folder','forecasts','generic_loading','goals','group_loading','groups','hierarchy','home','household',
		'insights','investment_account','lead','link','location','log_a_call','marketing_actions','merge','metrics','news',
		'note','operating_hours','opportunity','orders','people','performance','person_account','photo','poll','portal','post',
		'pricebook','process','product','product_consumed','product_item','product_item_transaction','product_required',
		'product_transfer','question_best','question_feed','quotes','recent','record','related_list','relationship','report',
		'resource_absence','resource_capacity','resource_preference','resource_skill','reward','rtc_presence','sales_path',
		'scan_card','service_appointment','service_contract','service_report','service_resource','service_territory',
		'service_territory_member','skill','skill_entity','skill_requirement','social','solution','sossession','task','task2',
		'team_member','thanks','thanks_loading','timeslot','today','topic','unmatched','user','work_order','work_order_item',
		'work_type'};

	public class Indicator {
		public string Color {get;set;}
		public string Value {get;set;}
		public Boolean Display {get;set;}
		public string Hover {get;set;}
		public String iType {get;set;}

		public Indicator(String value, String color, Boolean display, String hover, String iType) {
			this.Value = value; this.Color = color; this.Display = display; this.Hover = hover; this.iType = iType;
		}
	}

	public class WeathervaneException extends Exception {}

}