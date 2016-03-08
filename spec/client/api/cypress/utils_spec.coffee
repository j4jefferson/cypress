describe "$Cypress.Utils API", ->
  enterCommandTestingMode()

  describe "#filterOutOptions", ->
    it "returns new obj based on the delta from the filter", ->
      obj = $Cypress.Utils.filterOutOptions {visible: true, exist: false, foo: "bar"}, {visible: null, exist: false}
      expect(obj).to.deep.eq {visible: true}

    it "returns undefined if nothing is different", ->
      obj = $Cypress.Utils.filterOutOptions {foo: "foo", bar: "bar"}, {foo: "foo"}
      expect(obj).to.be.undefined

    it "normalizes objects with length property", ->
      obj = $Cypress.Utils.filterOutOptions {exist: true}, {visible: null, exist: false, length: null}
      expect(obj).to.deep.eq {exist: true}

  describe "#stringify", ->
    beforeEach ->
      @str = (str) ->
        $Cypress.Utils.stringify(str)

    context "Values", ->
      it "string", ->
        expect(@str("foo bar baz")).to.eq "foo bar baz"

      it "number", ->
        expect(@str(1234)).to.eq "1234"

      it "null", ->
        expect(@str(null)).to.eq "null"

      it "undefined", ->
        expect(@str(undefined)).to.eq ""

    context "Arrays", ->
      it "length <= 3", ->
        a = [["one", 2, "three"]]
        expect(@str(a)).to.eq "[one, 2, three]"

      it "length > 3", ->
        a = [[1,2,3,4,5]]
        expect(@str(a)).to.eq "Array[5]"

    context "Objects", ->
      it "keys <= 2", ->
        o = {visible: null, exists: true}
        expect(@str(o)).to.eq "{visible: null, exists: true}"

      it "keys > 2", ->
        o = {foo: "foo", bar: "baz", baz: "baz"}
        expect(@str(o)).to.eq "Object{3}"

      it "can have length property", ->
        o = {length: 10, foo: "bar"}
        expect(@str(o)).to.eq "{foo: bar, length: 10}"

    context "Functions", ->
      it "function(){}", ->
        o = (foo, bar, baz) ->
        expect(@str(o)).to.eq "function(){}"

    context "Elements", ->
      it "stringifyElement", ->
        o = $("div:first")
        expect(@str(o)).to.eq "<div#mocha>"

  describe "#hasElement", ->
    it "is true on jQuery objects", ->
      body = @cy.$$("body")
      expect($Cypress.Utils.hasElement(body)).to.be.true

    it "is true on DOM objects", ->
      body = @cy.$$("body").get(0)
      expect($Cypress.Utils.hasElement(body)).to.be.true

    _.each [{}, [], [{}], 1, "", true], (value) ->
      it "is false on: #{typeof value}", ->
        expect($Cypress.Utils.hasElement(value)).to.be.false

  describe "#stringifyElement", ->
    it "returns <window>", ->
      str = $Cypress.Utils.stringifyElement(window)
      expect(str).to.eq("<window>")

    it "returns <document>", ->
      str = $Cypress.Utils.stringifyElement(document)
      expect(str).to.eq("<document>")

    context "long form", ->
      it "includes wraps element in gt/ls", ->
        input = $("<input />")
        @cy.$$("body").append(input)

        str = $Cypress.Utils.stringifyElement(input)
        expect(str).to.eq "<input>"

    context "short form", ->
      it "returns element", ->
        body = @cy.$$("body")

        str = $Cypress.Utils.stringifyElement(body, "short")
        expect(str).to.eq "<body>"

      it "returns element + id", ->
        div = $("<div id='id' />")
        @cy.$$("body").append(div)

        str = $Cypress.Utils.stringifyElement(div, "short")
        expect(str).to.eq "<div#id>"

      it "uses element class", ->
        div = $("<div class='class foo bar' />")
        @cy.$$("body").append(div)

        str = $Cypress.Utils.stringifyElement(div, "short")
        expect(str).to.eq "<div.class.foo.bar>"

      it "uses name, id, and class", ->
        div = $("<div id='baz' class='foo' />")
        @cy.$$("body").append(div)

        str = $Cypress.Utils.stringifyElement(div, "short")
        expect(str).to.eq "<div#baz.foo>"

      it "can stringify svg", ->
        svg = $('<svg id="svg123" class="icon icon-svg" width="100" height="100"><rect class="node" fill="red" width="50" height="50" x="25" y="25"></rect></svg>')
        @cy.$$("body").append(svg)

        str = $Cypress.Utils.stringifyElement(svg, "short")
        expect(str).to.eq("<svg#svg123.icon.icon-svg>")

      it "gets updated class names", ->
        div = $("<div id='baz' class='foo' />")
        div.prop("class", "foo bar")
        @cy.$$("body").append(div)

        str = $Cypress.Utils.stringifyElement(div, "short")
        expect(str).to.eq("<div#baz.foo.bar>")

      it "returns array of els", ->
        lis = @cy.$$("li")

        str = $Cypress.Utils.stringifyElement(lis, "short")
        expect(str).to.eq "[ <li>, #{lis.length - 1} more... ]"

      it "stringifies array of elements", ->
        appendButton = =>
          @cy.$("body").append $("<button class='stringify'>b</button>")

        _.times 3, appendButton

        btns = @cy.$$(".stringify")
        str  = $Cypress.Utils.stringifyElement(btns, "short")
        expect(str).to.eq "[ <button.stringify>, 2 more... ]"

    context "#convertHtmlTags", ->
      it "converts opening brackets to tags", ->
        html = $Cypress.Utils.convertHtmlTags "[strong]foo"
        expect(html).to.eq "<strong>foo"

      it "converts closing brackets to tags", ->
        html = $Cypress.Utils.convertHtmlTags "foo[/strong]"
        expect(html).to.eq "foo</strong>"

      it "converts opening brackets with attrs", ->
        html = $Cypress.Utils.convertHtmlTags "[i class='fa-circle']foo"
        expect(html).to.eq "<i class='fa-circle'>foo"

  describe "#plural", ->
