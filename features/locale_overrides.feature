Feature: Locale overrides
  As a hacker of CSL styles
  I want to overrice localized terms
  In the locale section of a CSL style

  @locale-override @page-range
  Scenario: Page range delimiter override
    Given the following style:
      """
      <style page-range-format="expanded">
        <locale>
          <terms>
            <term name="page-range-delimiter">--</term>
          </terms>
        </locale>
        <citation>
          <layout>
            <text variable="page"/>
          </layout>
        </citation>
      </style>
      """
    When I cite the following items as "text":
      | page      |
      | 23        |
      | 23-5      |
      | 23-25     |
    Then the results should be:
      | 23        |
      | 23--25    |
      | 23--25    |
