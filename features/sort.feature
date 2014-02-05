Feature: Sorting
  As a hacker of cite processors
  I want to sort citation items
  According to the rules of a CSL style

  Scenario: Name sorting
    Given the following sort keys:
      """
      <sort>
        <key variable="author"/>
      </sort>
      """
    When I sort the following items:
      | author    |
      | Edelweis  |
      | ANZ-Group |
      | Aardvaark |
    Then the order should be:
      | ID-2      |
      | ID-1      |
      | ID-0      |

  Scenario: Name sorting macros
    Given the following sort keys:
      """
      <sort>
        <key macro="author"/>
      </sort>
      """
    And the following macro:
      """
      <macro name="author">
        <names variable="author">
          <name name-as-sort-order="all" and="symbol" sort-separator=", "
                initialize-with="." delimiter-precedes-last="never" delimiter=", "/>
          <label form="short" prefix=" (" suffix=".)" text-case="capitalize-first"/>
          <substitute>
            <names variable="editor"/>
            <text value="Anon"/>
          </substitute>
        </names>
      </macro>
      """
    When I sort the following items:
      | author    |
      | ABC       |
      | Aaa       |
    Then the order should be:
      | ID-1      |
      | ID-0      |
