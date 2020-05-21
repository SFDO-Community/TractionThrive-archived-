"""Locators for spring '20"""

cm_lex_locators = {
    "app_launcher": {
        "view_all_button": "//button[text()='View All']",
        "app_link": "//div[@data-name= '{}']//p[contains(@title,'')]",
    },
    "listbox": {
        "title": "//label[contains(text(), '{}')]/following::input[contains(@class, 'slds-input slds-combobox__input') and @role='textbox']",
        "value": "//*[contains(@class, 'slds-listbox__option') and @data-value='{}']",
    },
    "package": {
        "name": "//table[@class='list']/tbody/tr[{}]/th/a",
        "version": "//table[@class='list']/tbody/tr[{}]/td[4]",
    },
    "placeholder_lookup": {
        "lookup1": "//div[@class='slds-lookup__result-text' and contains(text(), '{}')]",
        "lookup2": "//mark[text() = '{}']/ancestor::a",
        "lookup3": "//div[contains(@class,'slds-listbox__option-text') and text()='{}']"
    },
    'button':'//input[contains(@value,"{}")]',
    'link-text':'//a[text()="{}"]',
    "close_tab": "//div[contains(@class, 'oneGlobalNav')]/descendant::*[@data-key='close']/ancestor::button",
    "frame": "//iframe[contains(@id, '{}') or contains(@title, '{}') or contains(@name, '{}')]",
    "input_placeholder": "//input[contains(@placeholder,'{}')]",
    "navigation_menu": "//button[@title='Show Navigation Menu']",
    "navigation_tab": "//button[@title='Show Navigation Menu']/../descendant::a[@title='{}']",
    "record_tab": "//a[@data-label='{}']",
    "rel_link":"//article[contains(@class, 'forceRelatedListCardDesktop')][.//img][.//span[@title='{}']]//table[contains(@class,'forceRecordLayout')]/tbody/tr[.//th/div/a[contains(@class,'textUnderline')]][.//td//a[text()='{}']]/th//a",
    "save": "//button[contains(@class, 'slds-button') and @type='button' and contains(text(), 'Save')]",
    "tabs":{
        "tab": "//a[contains(@class, 'tabHeader slds-context-bar__label-action') and @title='{}']",
    },
    "toast_message": "//div[contains(@class,'toastContent')]/child::div/span[text()='{}']",
    "toast_close": "//button[contains(@class,'slds-button_icon toastClose') and (@title='Close')]",
    "toast_close_community": "//button[contains(@class,'slds-button toastClose slds-notify__close')]",
    "users": {
        "user" : "//li[@data-node-id='ManageUsers']/div[@title='{}']/a[contains(@href,'ManageUsers')]",
        "login": "//table[@class='list']/tbody/tr[./td/input[contains(@title,'Advisor, DevTest')]]/td[@class='actionColumn']/a[text()='{}']",
        "login_user_detail": "//div[@data-message-id='loginAsSystemMessage']/descendant::span[contains(text(),'{}')]",
        "logout": "//a[@class='action-link']",
        "logout_user_detail": "//div[@data-message-id='loginAsSystemMessage']/descendant::a[contains(text(),'{}')]",
        "id":"//*[@id='{}']",

    },
    "contact_locators":{
        "community_login_error": "//div[contains(@class, 'slds-modal__container')]/div[contains(@class, 'modal-body')]/div[contains(text(), 'Looks like this portal user is not a member of a community or your community is down')]",
        "link": "//a[@title='{}']",
        "login_to_community": "//a[@title='Log in to Community as User']",
        "show_more_actions": "//div[contains(@class, 'actionsContainer')]/descendant::li[contains(@class, 'oneActionsDropDown')]/descendant::a[contains(@title, 'more actions')]",
    },

    "community_home_locators":{
        "contact_info_buttons": "//button[contains(@title,'{}')]",
        "contact_info_fields": "//label[contains(@class,'slds-form-element__label') and text()='{}']",
        "disabled_field": "//label[text()='{}']//following::input[@disabled]",
        "dropdown": "//label[text()='{}']/following::lightning-base-combobox//input",
        "dropdown_values": "//div[@lightning-basecombobox_basecombobox]/lightning-base-combobox-item[@data-value='{}']",
        "credential_save_button": "//button[text='{}']",
        "facility_info": "//label[text()='{}']//following::input[@title='{}']",
        "home_tab": "//a[@href='/TractionThrive/s/']",
        "staff_info": "//div/lightning-formatted-text[text()='{}']",
        "staff_contact_info": "//lightning-input[@data-field='{}']//input",
    },

    "community_template":{
        "add_metrics": "//a[text()='{}']",
        "template_button": "//button[@title='{}']",
        "template_header": "//div[contains(@class,'cb-StartWizard-TemplateTitle')]/header[contains(text(),'{}')]",
        "template_name"  : "//input[@id='cb-StartWizard-propertyInput-Name']",
        "title" : "//*[text()='{}']",
    }

}
