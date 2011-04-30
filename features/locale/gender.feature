Feature: Gendered terms
  As a user of CiteProc-Ruby
  I want to be able to define gendered terms
  In order to produce grammatically correct bibliographies

  @citation @v1.0.1 @locale @ordinals @gender
  Scenario: Render days as masculine, editions as feminine ordinals
    Given the CSL style:
    """
    <?xml version="1.0" encoding="utf-8"?>
    <style 
      xmlns="http://purl.org/net/xbiblio/csl"
      class="note"
      version="1.0.1">
      <info>
        <id />
        <title />
        <updated>2011-04-30T09:21:00+01:00</updated>
      </info>
      <locale>
        <terms>
          <term name="month-04" gender="masculine">April</term>
          <term name="edition" gender="feminine">Ausgabe</term>
          <term name="ordinal-01">XX</term>
          <term name="ordinal-01" gender-form="masculine">er</term>
          <term name="ordinal-01" gender-form="feminine">te</term>
      </terms>
      </locale>
      <citation>
        <layout delimiter="; ">
          <number variable="edition" form="ordinal"/>
          <text prefix=" " term="edition"/>
          <date prefix=", " variable="issued">
            <date-part name="day" form="ordinal" suffix=" "/>
            <date-part name="month"/>
          </date>
        </layout>
      </citation>
    </style>
    """
    When I process the following items:
      | id      | type | title   | edition | issued     |
      | ITEM-1  | book | Item 1  | 1       | 2011-04-01 |
    Then the result should be:
    """
    1te Ausgabe, 1er April
    """