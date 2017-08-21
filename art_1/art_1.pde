import hivis.common.*;
import hivis.data.*;
import hivis.data.reader.*;
import hivis.data.view.*;

// The source data
DataTable data;


// This is a flag to indicate that data is being (re)loaded and so the plot should not be drawn yet.
boolean noDataLoaded = true;

DataSeries heightSeries;
DataSeries weightSeries;
DataSeries waistSeries;
DataSeries BMISeries;
String[] smokerSeries;

int alpha = 15;
int[] randomRows;
int numRows = 10;
void setup() {
  size(1000, 700);
  colorMode(HSB, 360, 255, 255, 255);
  background(350);
  //textSize(15);
  noLoop();
  
  // Ask the user to select a spreadsheet to visualise.
  //selectInput("Select an excel file to visualise:", "fileSelected", sketchFile("NCHS_dataset.xlsx"));
}

void fileSelected(File selection) {
  if (selection == null) {
    println("No file selected.");
    exit();
  } else {
    // Get data from spread sheet. The SpreadSheetReader will automatically update the DataTable it provides.
    println("loading data");
    data = HV.loadSpreadSheet(HV.loadSSConfig().sourceFile(selection));

    println("\nLoaded data:\n" + data);
    
    heightSeries = data.get("height");
    weightSeries = data.get("weight");
    waistSeries = data.get("waist");
    BMISeries = data.get("bmi");
    smokerSeries = data.get("smoker").asStringArray();
    noDataLoaded = false;
    randomRows = new int[numRows];
    for (int i = 0; i < numRows; i++) {
      randomRows[i] = int(random(data.length()));
    }
    
    loop();
  }
  
  noFill();
  strokeWeight(3);
}




void draw() {
    
  fill(360, alpha);
  noStroke();
  rect(0, 0, width, height);
  
  filter(BLUR, .7);
  
  ////println(frameCount);
  if (noDataLoaded) {
    selectInput("Select an excel file to visualise:", "fileSelected", sketchFile("NCHS_dataset.xlsx"));
  } 
  
  else {

    if (frameCount % 30 == 0) {
      println("updating rows");
      updateRows();
    }
   
    for (int i = 0; i < randomRows.length; i++) {
      int row = randomRows[i];
      float cx = width/2.0;
      float cy = height/2.0;
      float r = row * 360/data.length();
      randomSeed(row);
      float dx = sin(radians(r  + random(-3.1, 3.1) * frameCount%90)) * 20;
      float dy = cos(radians(r)) * 20;
      float px = 0;
      float py = 0;


      stroke(getColour(row));
      
      float we = weightSeries.getFloat(row);
      float wa = waistSeries.getFloat(row);
      float hi = heightSeries.getFloat(row);

      float count = 0;
      while (onScreen(cx, cy)) {
        count += (row % 9)/10 + .1;
        noise(px/10);
        px = cx;
        py = cy;
        noiseSeed(int(we * count * 10));
        cx += dx + noise(frameCount + count)/8 * we;
        noiseSeed(int(wa * hi * count * 5));
        cy += dy + noise(frameCount + count)/8 * we;
        if (isSmoker(row)) {
          ellipse(cx, cy, wa*10, hi*5);
        } 
        else {  
          line(cx, cy, px, py);
        }
      }
    }
  }

}


boolean onScreen(float x, float y) {
  if (0 < x && x < width) {
    if (0 < y && y < height) {
      return true;
    }
  }
  return false;
}


color getColour(int r) {
  float min = BMISeries.min().getFloat();
  float max = BMISeries.max().getFloat();
  float bmi = (BMISeries.getFloat(r) - min)/max * 200 + 150;
  color c = color(bmi, 200, 220, alpha * 2);
  return c;
}

boolean isSmoker(int r) {

  if (smokerSeries[r].equals("no")) {
    return false;
  }
  return true;
}


void updateRows() {
  for (int i = 0; i < randomRows.length-1; i++) {
    randomRows[i] = randomRows[i+1];
  }
  randomRows[randomRows.length-1] = int(random(data.length()));
}