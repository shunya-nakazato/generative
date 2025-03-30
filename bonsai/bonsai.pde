class Branch {
  float this_x, this_y;
  float this_endx, this_endy;
  float this_weight, this_last_weight, this_length, this_angle;
  float this_age = 0;
  float[][] this_last_boundary_points = {};
  float this_length_noise = random(10);
  float this_weight_noise = random(10);
  float this_angle_noise = random(10);
  float this_x_noise = 1;
  float this_y_noise = random(10);
  float this_branch_probability = 0.90;
  boolean this_end_flag = false;
  Branch[] branches = {};
  
  Branch(float len, float weight, float angle, float x, float y, float[][] boundary_points) {
    this_x = x;
    this_y = y;
    this_length = len;
    this_last_weight = weight;
    this_weight = weight;
    this_angle = angle;
    float radian = radians(this_angle);
    float[][] this_boundary_points = boundary_points;
    for(int i=0; i<this_last_weight; i++) {
      float d = i - (this_last_weight);
      float x_d = this_x + (d * sin(radian));
      float y_d = this_y + (d * cos(radian));
      float[] point = {x_d, y_d};
      this_boundary_points = (float[][])append(this_boundary_points, point);
    }
    this_last_boundary_points = this_boundary_points;
  };
  
  void step() {
    this_age++;

    if(this_weight > 20) {
      this_branch_probability = 0.90;

      this_angle = this_angle + noise(this_angle_noise) * 60 - 30;
      if(this_angle > 360) { this_angle -= 360; }
      if(this_angle < 0) { this_angle += 360; }

      if (this_length > minimun_len) {
        this_length = this_length - (noise(this_length_noise) * 0.2 + 0.2);
      }
      
      this_weight = this_weight - (((noise(this_weight_noise) * 1.0 + 1.0)));
      
      this_length_noise += 0.03;
      this_weight_noise += 0.03;
      this_angle_noise += 0.3;

      addBranch();
      drawMe();
    } 
    else if (this_weight > 12.5) {
      this_branch_probability = 0.8;

      this_angle = this_angle + noise(this_angle_noise) * 45 - 22.5;
      if(this_angle > 360) { this_angle -= 360; }
      if(this_angle < 0) { this_angle += 360; }

      if (this_length > minimun_len) {
        this_length = this_length - (noise(this_length_noise) * 0.5 + 0.5);
      }
      
      this_last_weight = this_weight;
      this_weight = this_weight - (((noise(this_weight_noise) * 0.25 + 0.25)));
      
      this_length_noise += 0.03;
      this_weight_noise += 0.03;
      this_angle_noise += 0.3;
      
      addBranch();
      drawMe();
    }
    else if (this_weight > 3.0) {
      this_branch_probability = 0.85;

      this_angle = this_angle + noise(this_angle_noise) * 45 - 22.5;
      if(this_angle > 360) { this_angle -= 360; }
      if(this_angle < 0) { this_angle += 360; }

      if (this_length > minimun_len) {
        this_length = this_length - (noise(this_length_noise) * 0.5 + 0.5);
      }

      this_weight = this_weight - (((noise(this_weight_noise) * 0.1 + 0.1)));

      this_length_noise += 0.03;
      this_weight_noise += 0.03;
      this_angle_noise += 0.3;
      
      addBranch();
      drawMe();
    }
    else {
      drawLeaf(this_x, this_y);
    }
    for(int i=0; i<branches.length; i++) {
      branches[i].step();
    }
  }

  void addBranch() {
    if(random(1) > this_branch_probability) {
      float branch_angle = this_angle + random(120) + 30;
      float branch_length = this_length;
      float branch_weight = this_weight * (random(1) * 0.5 + 0.5) * 0.8;
      branches = (Branch[])append(branches, new Branch(branch_length, branch_weight, branch_angle, this_x, this_y, this_last_boundary_points));
    }
  }

  void autoPrune() {
    // 美的価値に基づく自動剪定ロジック

    // 1. 交差する枝を剪定
    for(int i=0; i<branches.length; i++) {
      if(branches.length > 1 && i < branches.length - 1) {
        Branch branch1 = branches[i];
        for(int j=i+1; j<branches.length; j++) {
          Branch branch2 = branches[j];
          // 単純化した交差判定 (実際にはもっと複雑)
          float angle_diff = abs(branch1.this_angle - branch2.this_angle);
          if(angle_diff < 20 || angle_diff > 340) {
            // 角度が近すぎる場合、若い方の枝を剪定
            if(branch1.this_age < branch2.this_age) {
              // branch1.is_pruned = true;
            } else {
              // branch2.is_pruned = true;
            }
          }
        }
      }
    }

    // 2. 垂直に伸びすぎた枝を剪定
    for(int i=0; i<branches.length; i++) {
      float branch_angle = branches[i].this_angle % 360;
      if((branch_angle > 80 && branch_angle < 100) || 
          (branch_angle > 260 && branch_angle < 280)) {
        // ほぼ垂直な枝を確率的に剪定
        if(random(1) < 0.3) {
          // branches[i].is_pruned = true;
        }
      }
    }

    // 3. 全体のバランスを考慮した剪定
    // このロジックは実装が複雑なため省略
  }

  void drawMe() {
    float radian = radians(this_angle);

    noFill();
    strokeWeight(strokeWeight);

    this_endx = this_x + (this_length * cos(radian));
    this_endy = this_y + (this_length * sin(radian));

    float[][] boundary_points = {};
    float x_noise = this_x_noise;
    for(int i=0; i<this_weight; i++) {
      float d = i - (this_weight);
      float x_d = this_endx + (d * sin(radian));
      float y_d = this_endy + (d * cos(radian));
      float[] point = {x_d, y_d};
      boundary_points = (float[][])append(boundary_points, point);

      stroke(30, (int)(noise(x_noise) * 50 + 25), (int)(noise(x_noise) * 25 + 25));
      line(this_last_boundary_points[i][0], this_last_boundary_points[i][1], boundary_points[i][0], boundary_points[i][1]);

      x_noise += 0.03;
      this_y_noise += 0.01;
    }
    //line(this_x, this_y, this_endx, this_endy);
    this_x = this_endx;
    this_y = this_endy;
    this_last_boundary_points = boundary_points;
  }
  
  void drawLeaf(float x, float y) {
    if(this_end_flag == true) return;

    int leaf_count = int(random(100, 120)); // 葉の密度を調整

    for(int i=0; i<leaf_count; i++) {
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
    this_end_flag = true;
  }
}

int size_width = 1280;
int size_height = 780;

int rect_y = 700;

int hachi_width = 300;
int hachi_height = 150;
float hachi_x = (size_width - hachi_width) /2 ;
float hachi_y = rect_y - hachi_height;

float strokeWeight = 2;
float init_len = 20;
float minimun_len = 2.0;
float init_weight = 100;
float init_angle = 270;
float[][] init_boundary_points = {};
float x = (size_width - init_weight) / 2;
float y = hachi_y + init_len;

Branch trunk;

void setup() {
  size(1280, 780);
  background(255);
  noFill();
  smooth();
  colorMode(HSB,360,100,100);
  
  PImage img = loadImage("hachi.png");
  
  fill(0);
  rect(0, rect_y, 1280, 1280);

  trunk = new Branch(init_len, init_weight, init_angle, x, y, init_boundary_points);
  trunk.step();
  image(img, hachi_x, hachi_y, hachi_width, hachi_height);
}

void draw() {
    trunk.step();
}
