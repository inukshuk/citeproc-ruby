Feature: Ordinalize numbers
  As a user of CiteProc-Ruby
  I want to be able to turn numbers into ordinals

  @citation @v1.0.1 @locale @ordinals
  Scenario: Render edition numbers as ordinals
    Given the CSL style:
    """
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
          <term name="ordinal-00">th</term>
          <term name="ordinal-01">st</term>
          <term name="ordinal-02">nd</term>
          <term name="ordinal-03">rd</term>
          <term name="ordinal-11">th</term>
          <term name="ordinal-12">th</term>
          <term name="ordinal-13">th</term>
      </terms>
      </locale>
      <citation>
        <layout delimiter=" ">
          <number variable="edition" form="ordinal"/>
        </layout>
      </citation>
    </style>
    """
    When I process the following items:
      | id      | type | title   | edition |
      | ITEM-1  | book | Item 1  | 1       |
      | ITEM-2  | book | Item 2  | 2       |
      | ITEM-3  | book | Item 3  | 3       |
      | ITEM-4  | book | Item 4  | 4       |
      | ITEM-5  | book | Item 5  | 10      |
      | ITEM-6  | book | Item 6  | 11      |
      | ITEM-7  | book | Item 7  | 12      |
      | ITEM-8  | book | Item 8  | 13      |
      | ITEM-9  | book | Item 9  | 14      |
      | ITEM-10 | book | Item 10 | 21      |
      | ITEM-11 | book | Item 11 | 22      |
      | ITEM-12 | book | Item 12 | 23      |
    Then the result should be:
    """
    1st 2nd 3rd 4th 10th 11th 12th 13th 14th 21st 22nd 23rd
    """