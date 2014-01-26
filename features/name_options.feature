Feature: Inheritance of Name Options
  As a style author
  I want name nodes to inherit attributes
  From the citation/bibliography and style nodes

  Scenario: Name options from bibliography node
    Given the following style node:
      """
      <bibliography name-form="short">
        <layout>
          <names variable="author">
            <name />
          </names>
        </layout>
      </bibliography>
      """
    When I render the following citation items as "html":
      | author                  |
      | John Doe                |
    Then the results should be:
      | Doe                     |

    Given the following style node:
      """
      <bibliography name-form="short">
        <layout>
          <names variable="author"/>
          <!--it works without a name node-->
        </layout>
      </bibliography>
      """
    When I render the following citation items as "html":
      | author                  |
      | John Doe                |
    Then the results should be:
      | Doe                     |

