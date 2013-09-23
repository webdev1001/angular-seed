# TODO use this convention for the other specs
describe "module: myApp.resources", ->
  beforeEach module "myApp.resources"

  describe "service: Products", ->
    $rootScope = null
    $httpBackend = null
    Products = null

    beforeEach inject (_$rootScope_, _$httpBackend_, _Products_) ->
      $rootScope = _$rootScope_
      $httpBackend = _$httpBackend_
      Products = _Products_

    it "is defined", ->
      expect(Products).to.not.be.undefined

    describe ".query", ->
      before -> @products = [{ name: "foo" }, { name: "bar" }]

      it "is defined", ->
        expect(Products.query).to.not.be.undefined

      it "queries for the records", ->
        $httpBackend.whenGET("/api/products.json").respond(@products)

        promise = Products.query().$promise

        $httpBackend.flush()

        products = null
        $rootScope.$apply ->
          promise.then (_products_) -> products = _products_

        expect(products).to.have.length 2

        # TODO write specs for `product.priceWithDiscount`
        product = products[0]
        expect(product).to.be.an.instanceof(Products)

        expect(product.hasDiscount).to.not.be.undefined
        expect(product.hasDiscount()).to.be.false

    describe "#hasDiscount", ->
      product = null
      beforeEach inject (Products) ->
        product = new Products(discount: @discount)

        # custom chai property for checking product's discount
        chai.Assertion.addProperty "discount", ->
          subject = @_obj

          @assert subject.hasDiscount(),
            "expected #\{this} to have discount",
            "expected #\{this} to not have discount"

      it "is defined", ->
        expect(product.hasDiscount).to.not.be.undefined

      context "when the discount is not defined", ->
        before -> @discount = undefined

        it "returns false", ->
          expect(product).to.not.have.discount

      context "when the @discount is null", ->
        before -> @discount = null

        it "returns false", ->
          expect(product).to.not.have.discount

      context "when the @discount is 0", ->
        before -> @discount = 0

        it "returns false", ->
          expect(product).to.not.have.discount

      context "when the @discount < 0", ->
        before -> @discount = -10

        it "returns false", ->
          expect(product).to.not.have.discount

      context "when the @discount is > 0", ->
        before -> @discount = 10

        it "returns true", ->
          expect(product).to.have.discount
