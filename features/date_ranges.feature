Feature: Rendering date ranges and seasons
  As a hacker of cite processors
  I want to render date ranges and seasons
  As described in the CSL specification

  @date @range
  Scenario: Range delimiters are drawn from the largest differing date part
    Given the following style node:
      """
      <date variable="issued">
        <date-part name="day" suffix=" " range-delimiter="-"/>
        <date-part name="month" suffix=" "/>
        <date-part name="year" range-delimiter="/"/>
      </date>
      """
    When I render the following citation items as "text":
      | issued                                   |
      | {"date-parts":[[2008,5,1],[2008,5,4]]}   |
      | {"date-parts":[[2008,5],[2008,7]]}       |
      | {"date-parts":[[2008,5],[2009,6]]}       |
    Then the results should be:
      | 1-4 May 2008       |
      | May–July 2008      |
      | May 2008/June 2009 |

  @date @season
  Scenario: Season terms take the place of the month term
    Given the following style node:
      """
      <date variable="issued">
        <date-part name="month" suffix=" "/>
        <date-part name="year"/>
      </date>
      """
    When I render the following citation items as "text":
      | issued                                   |
      | {"date-parts":[[2008,5]]}                |
      | {"date-parts":[[2009]],"season":4}       |
      | {"date-parts":[[2009,24]]}               |
      | {"date-parts":[[2009]],"season":"Winter"} |
      | {"date-parts":[[2009]],"season":"Holiday"} |
      | {"date-parts":[[2009,5]],"season":"12:00"} |
    Then the results should be:
      | May 2008     |
      | Winter 2009  |
      | Winter 2009  |
      | Winter 2009  |
      | Holiday 2009 |
      | May 2009     |

  @date @season @range
  Scenario: Season ranges
    Given the following style node:
      """
      <date variable="issued">
        <date-part name="month" suffix=" "/>
        <date-part name="year"/>
      </date>
      """
    When I render the following citation items as "text":
      | issued                                   |
      | {"date-parts":[[1999,21],[1999,22]]}     |
      | {"date-parts":[[1999,21],[2001,22]]}     |
    Then the results should be:
      | Spring–Summer 1999      |
      | Spring 1999–Summer 2001 |
