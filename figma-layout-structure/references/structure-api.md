# Структура макета Figma — заметки об API

Загружай этот справочник только при написании JavaScript для инструмента записи Figma MCP. Каждый пункт ниже описывает ошибку, которая уже встречалась при построении такой структуры.

## Привязка контейнера

`maxWidth` доступен только дочернему элементу фрейма с автоматической компоновкой и действует, только если размер дочернего элемента — `FILL`. Порядок важен:

```js
const box = figma.createFrame();
box.name = "Container";
box.layoutMode = "VERTICAL";
box.fills = [];
box.clipsContent = false;
block.appendChild(box);                 // сначала родитель
box.layoutSizingHorizontal = "FILL";    // затем размер
box.layoutSizingVertical = "FILL";
box.setBoundVariable("maxWidth", bpVar);       // затем переменные
box.setBoundVariable("paddingLeft", mgVar);
box.setBoundVariable("paddingRight", mgVar);
```

Чтение переменных:

```js
const cols = await figma.variables.getLocalVariableCollectionsAsync();
const grid = cols.find(c => c.modes.some(m => /desktop|tablet|mobile/i.test(m.name)));
const byName = {};
for (const id of grid.variableIds) {
  const v = await figma.variables.getVariableByIdAsync(id);
  if (v) byName[v.name] = v;
}
const bpVar = byName["layout/grid/breakpoint"];
const mgVar = byName["layout/grid/margin"];
```

`setBoundVariable` принимает объект переменной или её ID. Если вызов незаметно ничего не делает (свойство остаётся `null`), в этот момент узел не был дочерним элементом `FILL` фрейма с автоматической компоновкой. Исправь порядок операций, а не повторяй вызов.

## Измеряй до изменения размера

При классификации дочерних элементов как «на всю ширину» или «содержимое колонки» используй ширину фрейма **до** изменения его размера:

```js
const oldW = frame.width;          // сначала запомни
frame.resize(newW, frame.height);  // затем измени размер
for (const c of frame.children) {
  const fullBleed = c.width >= oldW * 0.95;   // сравнивай с oldW, не с frame.width
}
```

Сравнение с новой шириной незаметно меняет классификацию всех дочерних элементов и разрушает макет.

## Смена родителя растягивает дочерние элементы

При добавлении узла во фрейм с автоматической компоновкой он немедленно становится элементом потока и может растянуться до размера родителя по поперечной оси ещё до выполнения следующей строки кода. Запомни размер и затем восстанови:

```js
const w = node.width, h = node.height;
box.appendChild(node);
node.layoutPositioning = "ABSOLUTE";   // выйди из потока
node.layoutSizingHorizontal = "FIXED";
node.layoutSizingVertical = "FIXED";
node.resize(w, h);                      // отмени растяжение
node.x = x; node.y = y;                 // координаты относительно нового родителя
```

Смена родителя не сохраняет абсолютное положение на холсте: после неё всегда явно задавай `x` и `y`.

## Абсолютное положение декора и масштабирование с покрытием

Фоновая графика сохраняет соотношение сторон. Равномерно масштабируй её фрейм и центрируй выходящую за блок часть вместо растягивания по пропорциям блока:

```js
const setScale = (n) => {
  if (n.type === "GROUP") { for (const c of n.children) setScale(c); return; }  // у GROUP нет constraints
  try { n.constraints = { horizontal: "SCALE", vertical: "SCALE" }; } catch (e) {}
};
for (const c of art.children) setScale(c);
art.clipsContent = true;
const k = newW / oldW;
art.resize(Math.round(art.width * k), Math.round(art.height * k));
art.layoutPositioning = "ABSOLUTE";
art.x = 0;
art.y = Math.round((blockHeight - art.height) / 2);   // одинаково обрежь сверху и снизу
```

Растягивание `1440 × 900` до `1920 × 1080` искажает одну ось на 11% — это заметно на лицах, корпусах колонок и окружностях. Равномерное масштабирование с обрезкой не даёт такого искажения.

Элементы интерфейса внутри фрейма графики (ряд целевых действий, подпись) масштабируются вместе с ним. Либо прими это для фотографической композиции, либо вынеси узел в контейнер и размести вручную.

## Ловушки поиска узлов

- `findOne(n => n.name === "Container")` может вернуть одноимённый узел внутри экземпляра компонента в другой части блока. Ищи непосредственных дочерних элементов:

```js
const box = block.children.find(c => c.name === "Container" && c.parent.id === block.id);
```

- Внутри экземпляра нельзя переопределить положение: установка `x` вызывает `This property cannot be overridden in an instance: relative-transform`. Перемещай сам экземпляр или перестрой его мастер-компонент.
- У узлов `GROUP` нет свойства `constraints`; рекурсивно обойди их потомков.
- `node.resize()` сбрасывает режимы размеров на `FIXED`, поэтому вызывай его **до** установки `layoutSizing*`.
- `layoutSizingVertical = "AUTO"` недопустим: варианты — `FIXED | HUG | FILL`, а сами фреймы принимают `primaryAxisSizingMode = FIXED | AUTO`.

## Блоки с автоматической компоновкой без контейнера

Если в блоке уже есть фрейм на месте контейнера, привяжи переменные к нему, а отступы самого блока установи в 0:

```js
block.paddingLeft = 0;
block.paddingRight = 0;
block.counterAxisAlignItems = "CENTER";      // вертикальный стек: центрирование по горизонтали
// block.primaryAxisAlignItems = "CENTER";   // горизонтальный стек: центрирование по горизонтали
for (const c of block.children) {
  if (c.layoutPositioning === "ABSOLUTE") continue;          // декор остаётся свободным
  if (!c.findOne(n => n.type === "TEXT")) continue;          // чистый фон остаётся на всю ширину
  c.layoutSizingHorizontal = "FILL";
  c.setBoundVariable("maxWidth", bpVar);
  if (!(c.boundVariables || {}).paddingLeft) {
    c.setBoundVariable("paddingLeft", mgVar);
    c.setBoundVariable("paddingRight", mgVar);
  }
}
```

Для экземпляров с ограниченной шириной (подвала, шапки) привязывай брейкпоинт к `width`, а центрирование поручай странице:

```js
footer.layoutSizingHorizontal = "FIXED";
footer.setBoundVariable("width", bpVar);
page.counterAxisAlignItems = "CENTER";
```

У шапки на всю ширину остаётся собственный внутренний контейнер: оболочка занимает весь холст, а внутренний ряд имеет `FILL`, `maxWidth` и боковые поля.

## Проверка готовой страницы

```js
const rows = [];
for (const b of page.children) {
  const pb = b.absoluteBoundingBox;
  const bad = [];
  for (const t of b.findAll(n => n.type === "TEXT" && n.visible)) {
    const r = t.absoluteBoundingBox; if (!r) continue;
    const l = Math.round(r.x - pb.x), rr = Math.round(r.x + r.width - pb.x);
    if (l < colLeft - 4 || rr > colRight + 4) bad.push([t.characters.slice(0, 16), l, rr]);
  }
  rows.push({ n: b.name, w: Math.round(b.width), bad });
}
return rows;
```

`n.visible` имеет значение true и для узла внутри скрытого фрейма, поэтому проверь цепочку родителей, прежде чем объявлять находку ошибкой. Слайды карусели за пределами холста (`x` далеко за краем) размещены там намеренно — сообщи о них, но не «исправляй».

## Снимки экрана

- Снимай блок целиком, а не внутренний фрейм: панели с белой заливкой малой непрозрачности незаметны на шахматной прозрачной подложке отдельного рендера.
- По умолчанию в снимок попадают перекрывающиеся соседние элементы; передай `contentsOnly: true`, если соседний блок заходит в кадр.
- Делай один снимок после сборки блока и ещё один после исправления. Не снимай неизменившийся фрейм повторно.
