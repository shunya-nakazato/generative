import java.util.List;
import java.util.ArrayList;

class Branch {
  float this_x, this_y;
  float this_endx, this_endy;
  float this_weight, this_last_weight, this_length, this_angle;
  float this_age = 0;
  float this_length_noise = random(10);
  float this_weight_noise = random(10);
  float this_angle_noise = random(10);
  float this_x_noise = 1;
  float this_y_noise = random(10);
  float this_branch_probability = 0.5;
  boolean this_end_flag = false;
  List<HashMap<String, Float>> this_positions = new ArrayList<>();
  List<HashMap<String, Float>> leaf_positions = new ArrayList<>();
  Branch[] branches = {};
  
  Branch(float length, float weight, float angle, float x, float y) {
    this_x = x;
    this_y = y;
    this_length = length;
    this_last_weight = weight;
    this_weight = weight;
    this_angle = angle;

    HashMap<String, Float> position = new HashMap<String, Float>();
    position.put("x", x);
    position.put("y", y);
    position.put("weight", weight);
    position.put("angle", angle);
    this_positions.add(position);
  };
  
  boolean step() {
    this_age++;

    if(this_weight > 50) {
      this_angle = this_angle + noise(this_angle_noise) * 60 - 30;
      if(this_angle > 360) { this_angle -= 360; }
      if(this_angle < 0) { this_angle += 360; }

      if (this_length > minimun_len) {
        this_length = this_length - (noise(this_length_noise) * 0.005 + 0.005) * init_length;
      }
      
      this_weight = this_weight - (noise(this_weight_noise) * 0.01 + 0.01) * init_weight;
      
      this_length_noise += 0.03;
      this_weight_noise += 0.03;
      this_angle_noise += 0.3;

      autoPrune();
      addBranch();
      updatePosition();
    } 
    else if (this_weight > 15) {
      this_angle = this_angle + noise(this_angle_noise) * 45 - 22.5;
      if(this_angle > 360) { this_angle -= 360; }
      if(this_angle < 0) { this_angle += 360; }

      if (this_length > minimun_len) {
        this_length = this_length - (noise(this_length_noise) * 0.1 + 0.1) * init_length;
      }

      this_weight = this_weight - (noise(this_weight_noise) * 0.1 + 0.1) * init_weight;

      this_length_noise += 0.03;
      this_weight_noise += 0.03;
      this_angle_noise += 0.3;

      autoPrune();
      addBranch();
      updatePosition();
    }
    else if (this_weight > 3.0) {
      this_angle = this_angle + noise(this_angle_noise) * 45 - 22.5;
      if(this_angle > 360) { this_angle -= 360; }
      if(this_angle < 0) { this_angle += 360; }

      if (this_length > minimun_len) {
        this_length = this_length - (noise(this_length_noise) * 0.3 + 0.3);
      }

      this_weight = this_weight - (noise(this_weight_noise) * 0.1 + 0.1);

      this_length_noise += 0.03;
      this_weight_noise += 0.03;
      this_angle_noise += 0.3;

      autoPrune();
      addBranch();
      updatePosition();
    }
    else {
      this_end_flag = true;
    }
    boolean end_flag = this_end_flag;
    for(int i=0; i<branches.length; i++) {
      boolean branch_end = branches[i].step();
      if(!branch_end) {
        end_flag = false;
      }
    }
    return end_flag;
  }

  void addBranch() {
    if(random(1) > this_branch_probability) {
      float branch_angle = this_angle + random(360);
      float branch_length = this_length;
      float branch_weight = this_weight * (random(1) * 0.5 + 0.5) * 0.8;
      branches = (Branch[])append(branches, new Branch(branch_length, branch_weight, branch_angle, this_x, this_y));
    }
  }

  void autoPrune() {
    // 美的価値に基づく自動剪定ロジック

    // 交差する枝を剪定
    for(int i=0; i<branches.length; i++) {
      if(branches.length > 1 && i < branches.length - 1) {
        for(int j=i+1; j<branches.length; j++) {
          float ax = branches[i].this_positions.get(0).get("x");
          float ay = branches[i].this_positions.get(0).get("y");
          float bx = branches[i].this_x;
          float by = branches[i].this_y;
          
          float cx = branches[j].this_positions.get(0).get("x");
          float cy = branches[j].this_positions.get(0).get("y");
          float dx = branches[j].this_x;
          float dy = branches[j].this_y;

          boolean is_intersect = doVectorsIntersect(ax, ay, bx, by, cx, cy, dx, dy);

          if(is_intersect) {
            // 角度が近すぎる場合、若い方の枝を剪定
            if(branches[i].this_age < branches[j].this_age) {
              branches[i]=branches[branches.length - 1];
              branches = (Branch[])shorten(branches);
            } else {
              branches[j]=branches[branches.length - 1];
              branches = (Branch[])shorten(branches);
            }
          }
        }
      }
    }

    // 垂直に伸びすぎた枝を剪定
    for(int i=0; i<branches.length; i++) {
      float branch_angle = branches[i].this_angle % 360;
      if((branch_angle > 70 && branch_angle < 110) || 
          (branch_angle > 250 && branch_angle < 290)) {
        branches[i]=branches[branches.length - 1];
        branches = (Branch[])shorten(branches);
      }
    }

    // 3. 全体のバランスを考慮した剪定
    // このロジックは実装が複雑なため省略
  }

  boolean doVectorsIntersect(float ax, float ay, float bx, float by, float cx, float cy, float dx, float dy) {
    // ABベクトルに対してCとDが異なる側にあるかを判定
    float crossProduct1 = crossProduct(ax, ay, bx, by, cx, cy);
    float crossProduct2 = crossProduct(ax, ay, bx, by, dx, dy);
    
    // CDベクトルに対してAとBが異なる側にあるかを判定
    float crossProduct3 = crossProduct(cx, cy, dx, dy, ax, ay);
    float crossProduct4 = crossProduct(cx, cy, dx, dy, bx, by);
    
    // 線分が交差するための条件：
    // 1. ABベクトルに対してCとDが異なる側にある（外積の符号が異なる）
    // 2. CDベクトルに対してAとBが異なる側にある（外積の符号が異なる）
    boolean intersect = (crossProduct1 * crossProduct2 < 0) && (crossProduct3 * crossProduct4 < 0);
    
    // 特殊なケース：いずれかの外積が0の場合（線分上に点がある場合）
    if (crossProduct1 == 0 && isPointOnSegment(ax, ay, bx, by, cx, cy)) return true;
    if (crossProduct2 == 0 && isPointOnSegment(ax, ay, bx, by, dx, dy)) return true;
    if (crossProduct3 == 0 && isPointOnSegment(cx, cy, dx, dy, ax, ay)) return true;
    if (crossProduct4 == 0 && isPointOnSegment(cx, cy, dx, dy, bx, by)) return true;
    
    return intersect;
  }

  float crossProduct(float ax, float ay, float bx, float by, float cx, float cy) {
      // ABベクトルとACベクトルの外積を計算
      float abx = bx - ax;
      float aby = by - ay;
      float acx = cx - ax;
      float acy = cy - ay;
      
      return abx * acy - aby * acx;
  }

  boolean isPointOnSegment(float ax, float ay, float bx, float by, float px, float py) {
    // 点が線分上にあるかを判定
      return Math.min(ax, bx) <= px && px <= Math.max(ax, bx) && Math.min(ay, by) <= py && py <= Math.max(ay, by);
  }

  void updatePosition() {
    HashMap<String, Float> position = new HashMap<String, Float>();
    float radian = radians(this_angle);
    this_x = this_x + (this_length * cos(radian));
    this_y = this_y + (this_length * sin(radian));
    position.put("x", this_x);
    position.put("y", this_y);
    position.put("weight", this_weight);
    position.put("angle", this_angle);
    this_positions.add(position);
  }

  void drawMe() {
    for(int i = 0; i < branches.length; i++) {
      branches[i].drawMe();
    }

    noFill();
    strokeWeight(strokeWeight);

    for(int i = 0; i < this_positions.size() - 1; i++) {
      float x = this_positions.get(i).get("x");
      float y = this_positions.get(i).get("y");
      float angle = this_positions.get(i).get("angle");
      float weight = this_positions.get(i).get("weight");
      
      float end_x = this_positions.get(i + 1).get("x");
      float end_y = this_positions.get(i + 1).get("y");
      float end_angle = this_positions.get(i + 1).get("angle");
      float end_weight = this_positions.get(i + 1).get("weight");
      
      float x_noise = this_x_noise;
      
      float radian = radians(angle);
      float[][] boundary_points = {};
      
      for(int j=0; j<weight; j++) {
        float d = j - (weight);
        float x_d = x + (d * sin(radian));
        float y_d = y + (d * cos(radian));
        float[] point = {x_d, y_d};
        boundary_points = (float[][])append(boundary_points, point);
      }

      float end_radian = radians(end_angle);
      float[][] end_boundary_points = {};
      
      for(int j=0; j<end_weight; j++) {
        float d = j - (end_weight);
        float x_d = end_x + (d * sin(end_radian));
        float y_d = end_y + (d * cos(end_radian));
        float[] point = {x_d, y_d};
        end_boundary_points = (float[][])append(end_boundary_points, point);

        stroke(30, (int)(noise(x_noise) * 50 + 25), (int)(noise(x_noise) * 25 + 25));
        line(boundary_points[j][0], boundary_points[j][1], end_boundary_points[j][0], end_boundary_points[j][1]);

        x_noise += 0.03;
        this_y_noise += 0.01;
      }
    }

    float leaf_x = this_positions.get(this_positions.size() - 1).get("x");
    float leaf_y = this_positions.get(this_positions.size() - 1).get("y");
    HashMap<String, Float> leaf_position = new HashMap<String, Float>();
    leaf_position.put("x", leaf_x);
    leaf_position.put("y", leaf_y);
    leaf_positions.add(leaf_position);
  }
  
  void drawLeaf() {
    for(int i = 0; i < branches.length; i++) {
      branches[i].drawLeaf();
    }
    
    for(int i = 0; i < leaf_positions.size(); i++) {
      float x = leaf_positions.get(i).get("x");
      float y = leaf_positions.get(i).get("y");
      int leaf_count = int(random(100, 120)); // 葉の密度を調整
  
      for(int j=0; j<leaf_count; j++) {
        float angle = random(220) + 180;
        if(angle > 360) { angle -= 360; }
        if(angle < 0) { angle += 360; }
  
        float radian = radians(angle);
        float leaf_length = random(15) + 10;
        float endx = x + (leaf_length * cos(radian));
        float endy = y + (leaf_length * sin(radian));
  
        noFill();
        strokeWeight(strokeWeight);
        stroke(100, (int)random(20) + 50, (int)random(20) + 50);
        line(x, y, endx, endy);
      }
    }
  }
}

int size_width = 1280;
int size_height = 780;

int rect_y = 780;

int hachi_width = 300;
int hachi_height = 150;
float hachi_x = (size_width - hachi_width) /2 ;
float hachi_y = rect_y - hachi_height;

float strokeWeight = 2;
float init_length = 18;
float minimun_len = 2.0;
float init_weight = 120;
float init_angle = 270;
float[][] init_boundary_points = {};
float x = (size_width - init_weight) / 2;
float y = hachi_y + init_length;

Branch trunk;

void setup() {
  size(1280, 780);
  background(255);
  noFill();
  smooth();
  colorMode(HSB,360,100,100);
  
  PImage img = loadImage("hachi.png");
  
  fill(0);
  // rect(0, rect_y, 1280, 1280);

  trunk = new Branch(init_length, init_weight, init_angle, x, y);
  trunk.step();
  image(img, hachi_x, hachi_y, hachi_width, hachi_height);
}

boolean is_draw = true;

void draw() {
  boolean end_flag = trunk.step();
  if(end_flag && is_draw) {
      trunk.drawMe();
      trunk.drawLeaf();
      is_draw = false;
  };
}

void exit() {
}