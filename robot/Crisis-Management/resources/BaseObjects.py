from robot.libraries.BuiltIn import BuiltIn


class BaseCMPage:
    @property
    def cm(self):
        return self.builtin.get_library_instance('CrisisManagement')
        @property
    def pageobjects(self):
        return self.builtin.get_library_instance("cumulusci.robotframework.PageObjects")

    @property
    def builtin(self):
        return BuiltIn()

    @property
    def cumulusci(self):
        return self.builtin.get_library_instance("cumulusci.robotframework.CumulusCI")

    @property
    def salesforce(self):
        return self.builtin.get_library_instance('cumulusci.robotframework.Salesforce')

    @property
    def selenium(self):
        return self.builtin.get_library_instance("SeleniumLibrary")