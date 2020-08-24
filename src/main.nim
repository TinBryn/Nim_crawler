import unittest
import uri
import htmlhelper

suite "already passing":

  const url = "https://www.forbes.com/sites/christophersteiner/2016/09/29/how-to-hire-better-engineers-ignore-school-degrees-and-past-projects/#ceda3f8360bf"

  test "check uri parsing":
    const uri = parseUri(url)

    check:
      uri.scheme == "https"
      uri.hostname == "www.forbes.com"
      uri.port == ""
      uri.path == "/sites/christophersteiner/2016/09/29/how-to-hire-better-engineers-ignore-school-degrees-and-past-projects/"
      uri.query == ""
      uri.anchor == "ceda3f8360bf"

  test "parsing svg urls":
    check:
      parseUri("SVG_logo.svg").path == "SVG_logo.svg"
      parseUri("./SVG_logo.svg").path == "/SVG_logo.svg"

  test "html parsing":
    check:
      absolutizePath("./page3", "/web-crawler-test-site/test4/cynical.html") == "/web-crawler-test-site/test4/page3"
      absolutizePath("./SVG_logo.svg", "/") == "/SVG_logo.svg"

suite "failing tests":
  test "test 1":
    check:
      1 == 2
