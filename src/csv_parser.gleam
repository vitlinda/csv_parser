import gleam/io
import gleam/string
import gleam/list
import simplifile.{type FileError}

pub type CsvError {
  CannotReadFile(reason: FileError)
  MissingHeaderRow
}

pub type Csv {
  // header: ["name", "age"]
  // rows: [
  //  ["Giacomo", "25"],
  //  ["Luca", "25"]
  // ]
  Csv(header: List(String), rows: List(List(String)))
}

pub type Separator {
  Comma
  Semicolon
  Tab
}

pub fn separator_to_string(separator: Separator) -> String {
  case separator {
    Comma -> ","
    Semicolon -> ";"
    Tab -> "\t"
  }
}

pub fn read(path: String, separator: Separator) -> Result(Csv, CsvError) {
  case simplifile.read(path) {
    Error(file_error) -> Error(CannotReadFile(file_error))
    Ok(content) -> {
      case string.split(content, "\n") {
        [] -> Error(MissingHeaderRow)
        [header_line, ..lines] -> {
          let header = string.split(header_line, separator_to_string(separator))
          let rows =
            lines
            |> list.filter(fn(line) { line != "" })
            |> list.map(fn(line) {
              string.split(line, separator_to_string(separator))
            })
          Ok(Csv(header, rows))
        }
      }
    }
  }
}

pub fn main() {
  case read("prova.csv", Comma) {
    Ok(Csv(headers, _rows)) -> {
      io.println("Headers: ")
      headers
      |> list.each(fn(header) { io.println(" - " <> header) })
    }
    Error(MissingHeaderRow) -> io.println("Missing headers")
    Error(CannotReadFile(simplifile.Enoent)) -> io.println("File doesn't exist")
    Error(CannotReadFile(_)) -> io.println("Cannot read file")
  }
}
