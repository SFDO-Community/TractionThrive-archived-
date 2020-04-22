public static void createCommunityContactUser() {

    // Create an account
    Account newAccount = new Account (name = 'Julian Account',
    BillingCity ='San Diego',
    BillingState ='CA',
    BillingCountry ='USA',
    BillingStreet ='12345 Island Ave.',
    BillingPostalCode ='92101'
    );
    
    insert newAccount;
    
    // Create a Contact related to Account
    Contact newContact = new Contact (
        FirstName = 'Julian',
        LastName = 'Joseph',
        AccountId = newAccount.Id,
        Email = 'jjoseph@salesforce.com',
        Status__c = 'On Staff'
    );
    
    insert newContact;
    
    // Set options to prevent user setup emails
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.EmailHeader.triggerUserEmail = false;       
    dmo.EmailHeader.triggerOtherEmail = false;
    dmo.EmailHeader.triggerAutoResponseEmail = false;       
    dmo.optAllOrNone = false;

    // Choose profile to assign user
    Profile profile = [select Id from Profile where Name = 'Customer Community - Medical Staff'];
    
    // Create user
    string nick = newContact.email!=null?newContact.email.substring(0, newContact.email.indexOf('@')):'';
    nick += Datetime.now().getTime();
    User newUser = new User(
                        alias = newContact.firstName, 
                        email = newContact.email, 
                        emailencodingkey = 'UTF-8', 
                        firstname = newContact.firstName, 
                        lastname = newContact.lastname, 
                        languagelocalekey = 'en_US', 
                        localesidkey = 'en_US', 
                        Contactid = newContact.Id,
                        timezonesidkey = 'Asia/Dubai', 
                        username = newContact.email,
                        CommunityNickname = nick,
                        ProfileId = profile.id,
                        IsActive = true);
    
    newUser.setOptions(dmo);
    insert newUser;
}

public static void assignCommunityPermissionSet() {
    PermissionSet ps = [SELECT id FROM PermissionSet WHERE Label = 'Einstein Analytics Community User'];
    User user = [SELECT id FROM User WHERE email = 'jjoseph@salesforce.com'];

    PermissionSetAssignment psa = new PermissionSetAssignment
    (PermissionSetId = ps.id, AssigneeId = user.id);
    insert psa;
}