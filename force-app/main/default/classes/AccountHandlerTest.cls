/**
 * @description Test class for AccountHandler
 * @author  Heather Purvis, Traction on Demand
 * @date    2020-05-12
 */
@IsTest
public with sharing class AccountHandlerTest {

    private final static String HA_ACCOUNT_NAME = 'Test AHT health auth';

    @IsTest
    static void accountHealthAuthNameUpdate(){
        String name = HA_ACCOUNT_NAME;

        Test.startTest();
        Account healthAuth = TestUtils.createAccountByRecordType(name, Constants.HEALTH_AUTH_RECORDTYPE_ID, null, true);
        Account hospital = TestUtils.createAccountByRecordType('hospital', Constants.HOSPITAL_RECORDTYPE_ID, healthAuth.Id, true);
        Account division = TestUtils.createAccountByRecordType('division', Constants.DIVISION_RECORDTYPE_ID, hospital.Id, true);
        Test.stopTest();

        healthAuth = [SELECT ID, Health_Authority__c FROM Account WHERE Id = :healthAuth.Id];
        hospital = [SELECT ID, Health_Authority__c FROM Account WHERE Id = :hospital.Id];
        division = [SELECT ID, Health_Authority__c FROM Account WHERE Id = :division.Id];

        System.assertEquals(name, healthAuth.Health_Authority__c, 'Expected health auth name to be stamped');
        System.assertEquals(name, hospital.Health_Authority__c, 'Expected health auth name to be stamped');
        System.assertEquals(name, division.Health_Authority__c, 'Expected health auth name to be stamped');
    }
}