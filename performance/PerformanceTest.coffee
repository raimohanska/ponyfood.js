Benchmark = require('benchmark')
Ponyfood = (require "../src/Ponyfood").Ponyfood

_ = Ponyfood._
f = 
  generator: ->
    streams = []
    {
      stream: ->
        counter = 0
        bus = new Ponyfood.Bus()
        bus.tick = -> @push(counter = counter + 1)
        streams.push(bus)
        bus
      tick: ->
        s.tick() for s in streams
      ticks: (count) ->
        @tick() for i in [1..count]
    }
  everyNth: (n, stream) ->
    stream.filter (x) -> x % n == 0
  withGenerator: (fun, rounds=100) ->
    gen = f.generator()
    fun(gen).onValue((v) -> )
    gen.ticks(rounds)
  combineTemplate: (gen, width, depth) ->
    if depth == 0
      gen.stream()
    else
      template = {}
      for i in [1..width]
        template[i] = f.combineTemplate gen, width, depth-1
      Ponyfood.combineTemplate(template)
  zip: (gen) ->
    gen.stream().zip(gen.stream())

suite = new Benchmark.Suite

suite.add 'combo', ->
  f.withGenerator(((gen) ->
    s = f.combineTemplate(gen, 2, 2)
    s.onValue ->
      f.combineTemplate(gen, 2, 4).onValue(->)
    s), 1)
suite.add 'zip', ->
  f.withGenerator (gen) ->
    f.zip(gen)
suite.add 'Ponyfood.combineTemplate.sample', ->
  f.withGenerator (gen) ->
    f.combineTemplate(gen, 5, 1)
      .sampledBy(f.everyNth(10, gen.stream())) 
suite.add 'Ponyfood.combineTemplate (deep)', ->
  f.withGenerator (gen) ->
    f.combineTemplate(gen, 3, 3)
suite.add 'Ponyfood.combineTemplate', ->
  f.withGenerator (gen) ->
    f.combineTemplate(gen, 5, 1)
suite.add 'EventStream.map', ->
  f.withGenerator (gen) ->
    gen.stream().map((x) -> x * 2)
suite.add 'EventStream.scan', ->
  f.withGenerator (gen) ->
    gen.stream().scan(0, (x,y) -> x+y)
suite.add 'EventStream.toProperty', ->
  f.withGenerator (gen) ->
    gen.stream().toProperty()
suite.on 'cycle', (event) ->
  console.log(String(event.target))
.on "error", (error) ->
  console.log(error)
.run({ 'async': false })
