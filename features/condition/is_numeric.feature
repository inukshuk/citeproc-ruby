Feature: Condition is numeric

  @citeproc-test @citation @v1.0
  Scenario: is numeric
    Given a CSL processor
    And the following items
    """
    [
        {
            "id": "ITEM-1", 
            "title": "Work 1", 
            "volume": "Volume 2",
            "type": "book"
        }, 
        {
            "id": "ITEM-2", 
            "title": "Work 2", 
            "volume": "2nd volume",
            "type": "book"
        },
        {
            "id": "ITEM-3", 
            "title": "Work 3", 
            "volume": "Second volume",
            "type": "book"
        }
    ]
    """
    And the CSL style
    """
    <style 
          xmlns="http://purl.org/net/xbiblio/csl"
          class="note"
          version="1.0">
      <info>
        <id />
        <title />
        <updated>2009-08-10T04:49:00+09:00</updated>
      </info>
      <citation>
        <layout>
          <choose>
            <if is-numeric="volume">
              <text value="Numeric true:" suffix=" "/>
              <number variable="volume"/>
            </if>
            <else>
              <text value="Numeric false:" suffix=" "/>
              <number variable="volume"/>
            </else>
          </choose>
        </layout>
      </citation>
    </style>
    """
    When I process the citation items
    """
    [
        [
            {
                "id": "ITEM-1"
            }
        ], 
        [
            {
                "id": "ITEM-2"
            }
        ], 
        [
            {
                "id": "ITEM-3"
            }
        ]
    ]
    """
    Then the result should be
    """
    Numeric true: 2
    Numeric true: 2
    Numeric false: Second volume
    """
