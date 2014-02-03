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
      | ID-1      |
      | ID-2      |
      | ID-0      |
