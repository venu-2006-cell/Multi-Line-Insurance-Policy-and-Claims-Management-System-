public with sharing class PremiumCalculator { 

    public class PremiumInputWrapper { 
        @InvocableVariable(required=true) 
        public Id policyId;  
    } 

    @InvocableMethod(label='Calculate Policy Premium' description='Calculates premium based on policy fields (VIN, Model Year, State).') 
    public static List<Decimal> calculatePremium(List<PremiumInputWrapper> inputs) { 
        List<Decimal> premiumResults = new List<Decimal>(); 
        
        if (inputs == null || inputs.isEmpty()) {
            return premiumResults;
        }

        // Collect Policy IDs
        Set<Id> policyIds = new Set<Id>(); 
        for (PremiumInputWrapper input : inputs) { 
            if (input.policyId != null) { 
                policyIds.add(input.policyId); 
            } 
        } 

        // Query policies using the correct API field name Policy__c
        Map<Id, Policy__c> policyMap = new Map<Id, Policy__c>([ 
            SELECT Id, VIN__c, Model_Year__c, Policy__c 
            FROM Policy__c 
            WHERE Id IN :policyIds 
        ]); 

        // Iterate through the inputs array directly to guarantee order matching
        for (PremiumInputWrapper input : inputs) { 
            Policy__c policy = policyMap.get(input.policyId);

            if (policy == null) {
                premiumResults.add(null);
                continue;
            }

            Decimal basePremium = 1000.00;  

            // State adjustments using Policy__c
            if (policy.Policy__c == 'CA') { 
                basePremium *= 1.15;  
            } else if (policy.Policy__c == 'TX') { 
                basePremium *= 1.05;  
            } 

            // Model Year adjustments
            if (policy.Model_Year__c != null && Integer.valueOf(policy.Model_Year__c) < 2018) { 
                basePremium += 100.00;  
            } 

            premiumResults.add(basePremium); 
        } 

        return premiumResults; 
    } 
}