Feature: Rendering CSL choose nodes
  As a hacker of cite processors
  I want to render citation items
  Using CSL choose nodes


  Scenario: Inherited delimiter
    Given the following style node:
      """
      <group delimiter=", ">
        <choose>
          <if type="article-journal article-magazine" match="none">
            <text variable="genre"/>
            <text variable="publisher"/>
            <text variable="publisher-place"/>
          </if>
        </choose>
      </group>
      """
    When I render the following citation item as "html":
      | type            | book            |
      | genre           | Nature          |
      | publisher       | William Collins |
      | publisher-place | Glasgow         |
    Then the result should be: Nature, William Collins, Glasgow
